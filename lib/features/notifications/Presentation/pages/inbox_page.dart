import 'package:flutter/material.dart';
import 'package:spreadit_crossplatform/features/messages/presentation/pages/message_inbox.dart';
import 'package:spreadit_crossplatform/features/notifications/Data/get_total_notifications.dart';
import 'package:spreadit_crossplatform/features/notifications/Data/mark_as_read.dart';
import 'package:spreadit_crossplatform/features/notifications/Presentation/pages/notification_page.dart';
import '../../../generic_widgets/custom_bar.dart';
import 'package:spreadit_crossplatform/features/notifications/Data/get_notifications.dart';
import 'package:spreadit_crossplatform/features/notifications/Data/get_recommended_community.dart';
import 'package:spreadit_crossplatform/features/notifications/Data/notifications_class_model.dart';
import 'package:spreadit_crossplatform/features/loader/loader_widget.dart';

/// A StatefulWidget representing the Saved page where users can view their saved posts and comments.
class InboxPage extends StatefulWidget {
  final void Function(int)? onChangeHomeSubCategory;
  final bool isAllRead;
  const InboxPage({
    Key? key,
    this.onChangeHomeSubCategory,
    this.isAllRead = false,
  }) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int _selectedIndex = 0;
  List<Notifications> todayNotifications = [];
  List<Notifications> earlierNotifications = [];
  List<Notifications> notifications = [];
  bool isLoading = true;
  Notifications? recommendedCommunity;
  bool isAllRead = false;
  int unreadNotifications = -1;

  @override
  void initState() {
    super.initState();
    fetchData();
    setState(() {
      isAllRead = widget.isAllRead;
    });
    unreadNotificationsCount();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onChangeHomeSubCategory!(index + 7);
  }

  Future<void> getSuggestedCommunity() async {
    recommendedCommunity = await getRecommendedCommunity();
    DateTime now = DateTime.now();
    DateTime date = recommendedCommunity!.createdAt;
    bool isToday = (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day);
    setState(() {
      if (isToday) {
        todayNotifications.add(recommendedCommunity!);
      } else {
        earlierNotifications.add(recommendedCommunity!);
      }
    });
  }

  Future<void> fetchData() async {
    try {
      notifications = await fetchNotifications();
      if (notifications.isEmpty) {
        await getSuggestedCommunity();
      } else {
        final today = DateTime.now().toLocal();
        setState(() {
          todayNotifications = notifications.where((n) {
            final notificationDate = n.createdAt.toLocal();
            return notificationDate.year == today.year &&
                notificationDate.month == today.month &&
                notificationDate.day == today.day;
          }).toList();

          earlierNotifications = notifications.where((n) {
            final notificationDate = n.createdAt.toLocal();
            return !todayNotifications.contains(n) &&
                notificationDate.isBefore(today);
          }).toList();
          print('notifications state ${notifications.isNotEmpty}');

          print('todayNotifications  state ${todayNotifications.isNotEmpty}');
          print(
              'earliear notification state ${earlierNotifications.isNotEmpty}');
        });
      }
    } catch (e) {
      print(e);
      if (notifications.isEmpty) {
        await getSuggestedCommunity();
      }
    } finally {
      setState(() {
        isLoading = false;
      });
      print(isLoading);
    }
  }

  Future<void> markallnotificationsasRead() async {
    await MarkAsRead(type: 'all');
    setState(() {
      isAllRead = true;
    });
  }

  Future<void> unreadNotificationsCount() async {
    int number = await getNotificationUnreadCount();
    setState(() {
      unreadNotifications = number;
    });
  }

  /// Builds the selected page content based on the selected tab index.
  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return isLoading
            ? LoaderWidget(dotSize: 10, logoSize: 100)
            : NotificationPage(
                todayNotifications: todayNotifications,
                earlierNotifications: earlierNotifications,
                notifications: notifications,
                isAllRead: isAllRead,
              );

      case 1:
        return isLoading
            ? LoaderWidget(dotSize: 10, logoSize: 100)
            : MessageInbox();
      default:
        return LoaderWidget(
          dotSize: 10,
          logoSize: 100,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomBar(
          tabs: ['Notifications', 'Messages'],
          onIndexChanged: _onIndexChanged,
        ),
        Expanded(
          child: _buildSelectedPage(),
        ),
      ],
    );
  }
}
