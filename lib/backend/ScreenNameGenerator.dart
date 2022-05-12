import 'dart:math';

class ScreenNameGenerator{


  static List<String> adjectives = ['absurd','actor','adventurous','affable','agreeable','amusing','animated','annoying','banterer','brave','brazen','buffoon','busy bee','character','charmed','charming','cheesy','chucklesome','class-clown','clown','clownish','comedian','comic','comical','confident','crackpot','crazy','cuckoo','dag','deranged','droll','eccentric','enchanted','entertainer','entertaining','entranced','excited','facetious','fanatical','farcical','feral','ferocious','fierce','fool','funny','funny-man','funster','gagger','gagster','gleeful','good-humored','goofball','goofy','hilarious','hoaxer','hoot','humorous','hysterical','impressionist','jester','joker','jokester','jokey','jolly','josher','kidder','laugh','laughable','likeable','lively','loon','loose','loud','ludicrous','lunatic','mad','madcap','merry','mirthful','moron','nuts','nutty','off-the-wall','passionate','pest','playful','prankster','punster','quick','quiet','quipster','quirky','rib-tickling','rich','riot','riotous','risible','satirist','savage','scream','screwball','show-off','side-splitting','silly','slapstick','stand-up','stooge','tragic','trickster','unpredictable','uproarious','wacky','wag','waggish','weird','whimsical','wild','wise-cracker','witty','woo-woo','zany','zesty'];

  static List<String> nouns = ['Aardvark','Alligator','Alpaca','Anaconda','Ant','Anteater','Antelope','Aphid','Armadillo','Asp','Ass','Baboon','Badger','Barracuda','Bass','Bat','Dragon','Beaver','Bedbug','Bee','Bird','Bison','Bobcat','Buffalo','Butterfly','Buzzard','Camel','Carp','Cat','Caterpillar','Catfish','Cheetah','Chicken','Chimpanzee','Chipmunk','Cobra','Cod','Condor','Cougar','Cow','Coyote','Crab','Crane Fly','Cricket','Crocodile','Crow','Cuckoo','Deer','Dinosaur','Dog','Dolphin','Donkey','Dove','Dragonfly','Duck','Eagle','Eel','Elephant','Emu','Falcon','Ferret','Finch','Fish','Flamingo','Flea','Fly','Fox','Frog','Goat','Goose','Gopher','Gorilla','Guinea Pig','Hamster','Hare','Hawk','Hippopotamus','Horse','Hummingbird','Husky','Iguana','Impala','Kangaroo','Lemur','Leopard','Lion','Lizard','Llama','Lobster','Margay','Monkey','Moose','Mosquito','Moth','Mouse','Mule','Octopus','Orca','Ostrich','Otter','Owl','Ox','Oyster','Panda','Parrot','Peacock','Pelican','Penguin','Perch','Pheasant','Pig','Pigeon','Polar bear','Porcupine','Quagga','Rabbit','Raccoon','Rat','Rattlesnake','Red Wolf','Rooster','Seal','Sheep','Skunk','Sloth','Snail','Snake','Spider','Tiger','Whale','Wolf','Wombat','Zebra'];


  static String generateUsername(){
    String name = adjectives.elementAt(new Random().nextInt(adjectives.length-1));
    print(Random().nextInt(adjectives.length-1));
     name += nouns.elementAt(new Random().nextInt(nouns.length-1));
    print(Random().nextInt(nouns.length-1));
print(Random().nextInt(100));
    print(name);
     return name;
  }
}