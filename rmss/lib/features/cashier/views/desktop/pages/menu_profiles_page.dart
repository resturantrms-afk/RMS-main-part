import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_bloc.dart';
import 'package:rmss/core/blocs/menu_bloc/menu_state.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_bloc.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_event.dart';
import 'package:rmss/core/blocs/menu_profile_bloc/menu_profile_state.dart';
import 'package:rmss/core/models/menu_item_model.dart';
import 'package:rmss/core/models/menu_profile_model.dart';
import 'package:rmss/features/cashier/views/desktop/home%20widgets/cashier_top_bar.dart';
import 'package:rmss/features/cashier/views/desktop/pages/menu_profile_details_page.dart';

class MenuProfilesPage extends StatefulWidget {
  const MenuProfilesPage({super.key});

  @override
  State<MenuProfilesPage> createState() => _MenuProfilesPageState();
}

class _MenuProfilesPageState extends State<MenuProfilesPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CashierTopBar(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Operations',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        children: [
                          const TextSpan(text: 'Menu '),
                          TextSpan(
                            text: 'Profiles',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, menuState) {
                  List<MenuItemModel> allItems = [];
                  if (menuState is MenuLoaded) {
                    allItems = menuState.items;
                  }

                  return BlocBuilder<MenuProfileBloc, MenuProfileState>(
                    builder: (context, profileState) {
                      if (profileState is MenuProfilesLoaded) {
                        final profiles = profileState.profiles;
                        if (profiles.isEmpty) {
                          return Center(
                            child: Text(
                              'No Menu Profiles Found. Please contact admin.',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 1200
                                    ? 4
                                    : MediaQuery.of(context).size.width > 800
                                    ? 3
                                    : 2,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            return _MenuProfileCard(
                              profile: profiles[index],
                              allItems: allItems,
                            );
                          },
                        );
                      } else if (profileState is MenuProfileLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        );
                      } else if (profileState is MenuProfileError) {
                        return Center(
                          child: Text(
                            'Error: ${profileState.message}',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuProfileCard extends StatelessWidget {
  final MenuProfileModel profile;
  final List<MenuItemModel> allItems;

  const _MenuProfileCard({required this.profile, required this.allItems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get images for the collage
    final profileItems = allItems
        .where((i) => profile.menuItemIds.contains(i.id))
        .toList();
    final top4Items = profileItems.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuProfileDetailsPage(
                  profile: profile,
                  allItems: allItems,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Collage section
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: top4Items.isEmpty
                      ? Container(
                          color: colorScheme.surfaceContainer,
                          child: Icon(
                            Icons.fastfood,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : _buildCollage(top4Items, colorScheme),
                ),
              ),

              // 2. Details and Controls
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${profile.menuItemIds.length} Items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Divider(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: profile.isActive,
                                activeColor: colorScheme.primary,
                                onChanged: (val) {
                                  context.read<MenuProfileBloc>().add(
                                    ToggleMenuProfileActiveStatus(
                                      profile: profile,
                                      isActive: val,
                                      allCurrentMenuItems: allItems,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                profile.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: profile.isActive
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollage(List<MenuItemModel> items, ColorScheme colorScheme) {
    if (items.length == 1) {
      return _buildImage(items[0].imageUrl);
    } else if (items.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildImage(items[0].imageUrl)),
          const SizedBox(width: 2),
          Expanded(child: _buildImage(items[1].imageUrl)),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(items[0].imageUrl)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(items[1].imageUrl)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildImage(items.length > 2 ? items[2].imageUrl : ''),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildImage(items.length > 3 ? items[3].imageUrl : ''),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey.withValues(alpha: 0.1),
        child: const Center(child: Icon(Icons.restaurant, color: Colors.grey)),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) =>
          Container(color: Colors.grey.withValues(alpha: 0.2)),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.grey),
        ),
      ),
    );
  }
}
