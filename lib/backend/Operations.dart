import 'package:hitstorm/backend/Topic.dart';

class Operations{

  static List<Topic> hotTopics = [];

  static Future<Iterable<Topic>> getTestTopics(i)async{
    List<Topic> topics = [];
    for(int x = 0; x < 10; x++){
      topics.add(new Topic.test());
    }
    hotTopics = topics;
    return hotTopics;
  }

  static Topic newTopic(String name , String intro, String theme){
    Topic t = new Topic.createTopic(name, intro, theme);
    hotTopics.insert(0, t);
    return t;
  }
}