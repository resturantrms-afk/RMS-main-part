import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

type UserRole = "admin" | "cashier" | "kitchen" | "waiter" | "noRole";

interface UserData {
  deviceToken?: string;
  role?: UserRole;
  pushNotificationsEnabled?: boolean;
  pushCleaningAlertsEnabled?: boolean;
}

/**
 * Helper to send notifications to users of a specific role
 */
async function notifyRole(
  role: UserRole,
  title: string,
  body: string,
  checkCleaningAlertToggle: boolean = false
) {
  const snapshot = await admin.firestore().collection("users").where("role", "==", role).get();
  
  const tokens: string[] = [];
  snapshot.forEach((doc) => {
    const data = doc.data() as UserData;
    
    // Check user preferences
    if (checkCleaningAlertToggle) {
      if (data.pushCleaningAlertsEnabled === false) return;
    } else {
      if (data.pushNotificationsEnabled === false) return;
    }

    if (data.deviceToken && data.deviceToken !== "" && data.deviceToken !== "invalid") {
      tokens.push(data.deviceToken);
    }
  });

  if (tokens.length > 0) {
    // Send push notification via FCM
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body,
      },
    });
  }
}

/**
 * Triggered whenever an order is created, updated, or deleted
 */
export const onOrderWritten = onDocumentWritten("orders/{orderId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();

  // If order was deleted, do nothing
  if (!after) return;

  const orderStatus = after.status;
  const oldStatus = before ? before.status : null;
  const tableNumber = after.tableNumber;
  
  const isNew = !before;

  // 1. Kitchen Notification (New or Updated)
  if (orderStatus !== "paid") {
    let shouldNotify = isNew;
    if (!isNew && before && after) {
      const beforeItemsCount = Array.isArray(before.items) ? before.items.length : 0;
      const afterItemsCount = Array.isArray(after.items) ? after.items.length : 0;
      if (beforeItemsCount !== afterItemsCount) {
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      const title = isNew ? "New Order" : "Order Updated";
      const body = isNew
        ? `Table ${tableNumber} placed a new order.`
        : `Table ${tableNumber} order has been updated.`;
      
      await notifyRole("kitchen", title, body);
    }
  }

  // 2. Waiter Notification (Order Ready)
  if (orderStatus === "ready" && oldStatus !== "ready") {
    await notifyRole("waiter", "Order Ready", `Order is ready to be served.`);
  }

  // 3. Cashier & Admin Notification (Order Served)
  if (orderStatus === "served" && oldStatus !== "served") {
    const msg = `Order has been served.`;
    await notifyRole("cashier", "Order Served", msg);
    await notifyRole("admin", "Order Served", msg);
  }
});

/**
 * Triggered whenever a table is created, updated, or deleted
 */
export const onTableWritten = onDocumentWritten("tables/{tableId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();

  // If table was deleted, do nothing
  if (!after) return;

  const status = after.status;
  const oldStatus = before ? before.status : null;
  const tableNumber = after.tableNumber;
  const needsHelp = after.needsHelp === true;
  const oldNeedsHelp = before ? before.needsHelp === true : false;

  // Waiter Notification (Table Needs Cleaning or Help)
  if (status === "needsCleaning" && oldStatus !== "needsCleaning") {
    await notifyRole(
      "waiter", 
      "Table Needs Cleaning", 
      `Table ${tableNumber} just finished and needs cleaning.`,
      true // use pushCleaningAlertsEnabled instead of pushNotificationsEnabled
    );
  }
  
  if (needsHelp && !oldNeedsHelp) {
    await notifyRole(
      "waiter", 
      "Table Needs Help", 
      `Customer at Table ${tableNumber} needs your help.`
    );
  }
});

/**
 * Triggered whenever a user is created, updated, or deleted
 */
export const onUserWritten = onDocumentWritten("users/{userId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();

  // If user was deleted from Firestore, delete them from Firebase Auth as well
  if (before && !after) {
    const userId = event.params.userId;
    try {
      await admin.auth().deleteUser(userId);
      console.log(`Successfully deleted auth user: ${userId}`);
    } catch (error) {
      console.error(`Error deleting auth user ${userId}:`, error);
    }
  }
});

