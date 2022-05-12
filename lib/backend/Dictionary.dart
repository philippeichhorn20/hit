

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Dictionary{

  static int language  = 1; // 0 = englisch; 1 = deutsch

  static Map<String, String> dictionary = {

    "Delete this Post?": "Diesen Post löschen?",
    "Delete this Comment?": "Diesen Kommentar löschen?",
    "share": "Teilen",
    "Information": "Informationen",
    "Who we are": "Über uns",
    "Legal Documents": "Rechtliche Informationen",
    "Log Out" : "Ausloggen",
    "Delete Account" :"Account löschen",
    "Sorry we have a problem...": "Sorry, wir haben gerade ein Problem",
    "No results found": "Keine Ergebnisse",
    "I accept the terms of service": "Ich akzeptiere die Allgemeinen Nutzungsbestimmungen",
    "Themes": "Themen",
    "Delete": "Löschen",
    "Reset": "Wiederherstellen",
    'Give a short intro. \n\nDo not target people.':    'Gib einen kurzen Überblick. \n\nNicht auf Menschen abzielen.',
    "Topic": "Deine Frage",
    "Delete my Account": "Lösche meinen Account",
    "Do you want to delete this account?": "Möchtest du diesen Account löschen?",
    "Cancel": "Abbrechen",
    "Profane language has been detected":     "Profane Sprache wurde erkannt, bitte entfernen Sie diese",
    "Report this Post?": "Diesen Post melden?",
    "Report": "Melden",
    "added your comment": "dein Kommentar wurde hinzugefügt",
    "Report this Comment": "Diesen Kommentar melden",
"refresh to load": "Runterziehen um zu laden",
    "Legal": "Rechtliches",
    "Licenses": "Lizenzen",
    "My Topics": "Meine Posts",
    "My Comments": "Meine Kommentare",
    "Give us your feedback here!": "Wir freuen uns über Feedback",
    "Do you want to delete your account?": "Möchtest du deinen Account löschen?",
    "load more": "mehr laden",
    "loading more...": "wird geladen...",
    "no more results": "",
    "Your Comments and Posts need to be deleted seperately and before this step in order to remove all your personal data from the platform":
        "Um alle deine Daten von der Platform zu entfernen, musst du vor diesem Schritt deine Posts und Kommentare löschen.",
    "By clicking 'I Agree' you agree with our Terms and Conditions. Click here to see them.":
        "Durch das Klicken von 'Ich stimme zu', stimmst du den AGB's und den Privatsphäreeinstellungen der Plattform zu. Klick auf diese Fläche um diese einzusehen.",
"I Agree":"Ich stimme zu",
    "Groups: ": "Gruppen: "
  };



  static setLanguage(int i){
    language = i;
  }

  static String text(String s) {
    if (language == 0) {
      return s;
    } else if (language == 1) {
      String translation = dictionary[s];
      if (translation == null ) {
        print(s);
        return s;
      } else {
        return translation;
      }
    }
  }
}