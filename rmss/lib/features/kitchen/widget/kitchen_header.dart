import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rmss/core/constants/app_colors.dart';

class KitchenHeader extends StatefulWidget {
  const KitchenHeader({super.key});

  @override
  State<KitchenHeader> createState() => _KitchenHeaderState();
}

class _KitchenHeaderState extends State<KitchenHeader> {
  String _displayName = '...' ;

  @override
  void initState() {
    super.initState();
    _listenToUser();
  }

  void _listenToUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snap) {
      if (!mounted) return;
      final data = snap.data();
      if (data == null) return;
      setState(() {
        _displayName = (data['name'] as String?) ?? (data['displayName'] as String?) ?? 'Unknown';
      });
    }, onError: (_) {});
  }

  String _formattedTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // LEFT SECTION
          Row(
            children: [

              const Text(
                "CROWN",
                style: TextStyle(
                  color: Color(0xFFFF8C42),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 1,
                height: 25,
                color: Colors.white24,
              ),

              const SizedBox(width: 12),

              const Text(
                "Kitchen Console",
                style: TextStyle(
                  color: Color(0xFFF5E6D3),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // RIGHT SECTION
          Row(
            children: [

              const Icon(
                Icons.access_time,
                color: Color(0xFFFF8C42),
                size: 20,
              ),

              const SizedBox(width: 6),

              // Live clock
              StreamBuilder<DateTime>(
                stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                builder: (context, snapshot) {
                  final timeStr = snapshot.hasData ? '${snapshot.data!.hour.toString().padLeft(2,'0')}:${snapshot.data!.minute.toString().padLeft(2,'0')}' : _formattedTime();
                  return Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(width: 30),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cocoaBrown,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFFFF8C42),
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Chef de Cuisine",
                          style: TextStyle(
                            color: Color(0xFFF5E6D3),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          _displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}