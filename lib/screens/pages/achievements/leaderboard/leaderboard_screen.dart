import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Tutors This Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ranked by points earned from tutoring sessions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: Text('Overall')),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'This Month',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: Text('By Subject')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Top 3 Leaders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopLeader(
                  context,
                  position: 2,
                  name: 'Michael Chen',
                  subject: 'Computer Science',
                  points: '2,450',
                  imageUrl: 'https://picsum.photos/200/200?random=16',
                ),
                _buildTopLeader(
                  context,
                  position: 1,
                  name: 'Sarah Johnson',
                  subject: 'Mathematics',
                  points: '3,120',
                  imageUrl: 'https://picsum.photos/200/200?random=10',
                  isFirst: true,
                ),
                _buildTopLeader(
                  context,
                  position: 3,
                  name: 'David Lee',
                  subject: 'Chemistry',
                  points: '2,210',
                  imageUrl: 'https://picsum.photos/200/200?random=13',
                ),
              ],
            ),
            SizedBox(height: 20),
            // Rest of Leaderboard
            _buildLeaderboardItem(
              context,
              position: 4,
              name: 'Emily Rodriguez',
              detail: 'Economics | 1,980 pts',
              points: '1,980',
              imageUrl: 'https://picsum.photos/200/200?random=17',
            ),
            _buildLeaderboardItem(
              context,
              position: 5,
              name: 'Robert Wilson',
              detail: 'Physics | 1,870 pts',
              points: '1,870',
              imageUrl: 'https://picsum.photos/200/200?random=18',
            ),
            _buildLeaderboardItem(
              context,
              position: 6,
              name: 'Jennifer Adams',
              detail: 'English | 1,750 pts',
              points: '1,750',
              imageUrl: 'https://picsum.photos/200/200?random=19',
            ),
            _buildLeaderboardItem(
              context,
              position: 7,
              name: 'Alex Thompson',
              detail: 'Statistics | 1,620 pts',
              points: '1,620',
              imageUrl: 'https://picsum.photos/200/200?random=20',
            ),
            _buildLeaderboardItem(
              context,
              position: 8,
              name: 'John Doe',
              detail: 'Mathematics | 1,540 pts',
              points: '1,540',
              imageUrl: 'https://picsum.photos/200/200?random=2',
              isCurrentUser: true,
            ),
            _buildLeaderboardItem(
              context,
              position: 9,
              name: 'Maria Garcia',
              detail: 'Literature | 1,480 pts',
              points: '1,480',
              imageUrl: 'https://picsum.photos/200/200?random=21',
            ),
            _buildLeaderboardItem(
              context,
              position: 10,
              name: 'James Brown',
              detail: 'Computer Science | 1,420 pts',
              points: '1,420',
              imageUrl: 'https://picsum.photos/200/200?random=22',
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('View Full Leaderboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLeader(
    BuildContext context, {
    required int position,
    required String name,
    required String subject,
    required String points,
    required String imageUrl,
    bool isFirst = false,
  }) {
    Color positionColor;
    switch (position) {
      case 1:
        positionColor = Colors.amber;
        break;
      case 2:
        positionColor = Colors.blueGrey;
        break;
      case 3:
        positionColor = Colors.brown;
        break;
      default:
        positionColor = Colors.grey;
    }

    return Column(
      children: [
        Container(
          width: isFirst ? 100 : 80,
          height: isFirst ? 100 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isFirst ? Border.all(color: Colors.amber, width: 3) : null,
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: isFirst ? 50 : 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: positionColor,
                  ),
                  child: Center(
                    child: Text(
                      position.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(subject, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 5),
        Text(
          points,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context, {
    required int position,
    required String name,
    required String detail,
    required String points,
    required String imageUrl,
    bool isCurrentUser = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              position.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    position <= 3
                        ? position == 1
                            ? Colors.amber
                            : position == 2
                            ? Colors.blueGrey
                            : Colors.brown
                        : Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 16),
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  detail,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
