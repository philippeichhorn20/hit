

class Dictionary{

  static int language  = 1; // 0 = englisch; 1 = deutsch
  static List<String> english = [
    "Delete this Post?",
    "Delete this Comment?",
    "share",
    "Information",
    "Who we are",
    "Imprint",
    "Log Out",
    "Delete Account",
    "Sorry we have a problem...",
    "No results found",
    "I accept the terms of service",
    "Themes",
    "Delete",
    "Reset",
    'Give a short intro. \n\nDo not target people.',
    "Topic",
    "Delete my Account",
    "Do you want to delete this account?",
    "Cancel",
    "Profane language has been detected",
    "Report this Post?",
    "Report",
    "added your comment",
    "Report this Comment",
  ];
  static List<String> german = [
    "Lösche diesen Post",
    "Lösche diesen Kommentar",
    "Teilen",
    "Informationen",
    "Über uns",
    "Impressum",
    "Ausloggen",
    "Account löschen",
    "Sorry wir haben ein problem... Bitte versuchen Sie es erneut",
    "Nichts gefunden",
    "Ich akzeptiere die Nutzungsbedingungen",
    "Themen",
    "Löschen",
    "Wiederherstellen",
    'Gib einen kurzen Überblick. \n\nNicht auf Menschen abzielen.',
    "Titel",
    "Account löschen",
    "Wollen Sie den Account unwiederruflich löschen?",
    "Abbrechen",
    "Profane Sprache wurde erkannt, bitte entfernen Sie diese",
    "Möchtest du diesen Post melden?",
    "Melden",
    "Dein Kommentar wurde hinzugefügt",
    "Möchtest du diesen Kommentar melden?",
  ];

  static setLanguage(int i){
    language = i;
  }

  static String text(String s){
    int index = english.indexOf(s);
    if (index == -1){
      print("translation not found: $s");
      return s;
    }
    if(index > german.length){
      return s;
    }
    if(language == 0){
      return s;
    }else if(language == 1){
      return german[index];
    }else{
      return s;
    }
  }
}