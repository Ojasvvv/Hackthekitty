import 'dart:math' as math;
import '../../core/health/health_snapshot.dart';
import '../../shared/theme/mood_palette.dart';

class MoodEngine {
  // Configurable weights (can be tuned later)
  static const double targetSteps = 10000.0;
  static const double targetScreenTimeHours = 4.0;
  static const int maxTolerablePickups = 5;

  static double calculateActivityScore(int steps) {
    return (steps / targetSteps).clamp(0.0, 1.0);
  }

  static double calculateRestlessnessScore(int pickups) {
    return (pickups / maxTolerablePickups).clamp(0.0, 1.0);
  }

  static double calculateScreenTimePenalty(double screenTime) {
    if (screenTime <= targetScreenTimeHours) return 0.0;
    // Every hour above target is a 10% penalty
    return ((screenTime - targetScreenTimeHours) * 0.1).clamp(0.0, 0.5);
  }

  static MoodTier calculateMoodTier(HealthSnapshot snapshot) {
    final activityScore = calculateActivityScore(snapshot.stepCount);
    final restlessnessScore = calculateRestlessnessScore(snapshot.lateNightPickups);
    final screenTimePenalty = calculateScreenTimePenalty(snapshot.screenTimeHours);

    // Calculate a composite wellbeing score (0.0 to 1.0)
    // Activity (60%), calmness (40%)
    double rawScore = (activityScore * 0.6) + ((1.0 - restlessnessScore) * 0.4);
    
    // Apply penalty for excessive screen time
    final finalScore = (rawScore - screenTimePenalty).clamp(0.0, 1.0);

    if (finalScore >= 0.85) return MoodTier.thriving;
    if (finalScore >= 0.65) return MoodTier.good;
    if (finalScore >= 0.45) return MoodTier.neutral;
    if (finalScore >= 0.25) return MoodTier.low;
    return MoodTier.depleted;
  }

  static String generateDiaryEntry(HealthSnapshot snapshot, MoodTier tier, String catName) {
    final random = math.Random();
    
    // Dynamic factors
    final highScreenTime = snapshot.screenTimeHours > targetScreenTimeHours;
    final highSteps = snapshot.stepCount >= targetSteps;
    final lowSteps = snapshot.stepCount < 3000;
    
    if (tier == MoodTier.depleted) {
      if (highScreenTime && lowSteps) {
         final dialogues = [
           "$catName is exhausted just watching you. Put the glowing box down and move your legs!",
           "You stared at a screen for ${snapshot.screenTimeHours.toStringAsFixed(1)} hours and walked ${snapshot.stepCount} steps. $catName is deeply disappointed.",
           "Blink twice if you're trapped in the internet! $catName is considering a rescue mission.",
           "Is the gravity extra strong today? $catName thinks you've fused with the couch.",
           "$catName would judge you, but they're too tired from watching you do nothing."
         ];
         return dialogues[random.nextInt(dialogues.length)];
      }
      
      final dialogues = [
        "Meow-ch. ${snapshot.stepCount} steps? $catName has moved more in their sleep. Get up!",
        "Are you stuck to the couch? $catName can't relate, they sleep in boxes.",
        "$catName is considering scratching the furniture because your lack of movement offends them.",
        "Pathetic. You're making $catName look athletic, and they nap 16 hours a day.",
        "Is this a joke? ${snapshot.stepCount} steps? $catName's food bowl gets more action.",
        "$catName sighed so loudly it woke the neighbors. Move it, human!",
        "You have the energy of a sloth today. $catName is not impressed.",
        "If you don't move soon, $catName is going to claim your lap permanently.",
        "$catName is plotting a revolution because you clearly aren't in charge today.",
        "Even a Roomba gets more exercise than you did today, says $catName."
      ];
      return dialogues[random.nextInt(dialogues.length)];
    } else if (tier == MoodTier.thriving) {
      if (highSteps && !highScreenTime) {
          final dialogues = [
            "Purr-fect! ${snapshot.stepCount} steps and sensible screen time! $catName is glowing with pride.",
            "$catName thinks you're actually a cat in disguise today. Amazing energy!",
            "You're zooming like it's 3 AM! $catName highly approves of this behavior.",
            "$catName is inspired by your majestic leg movement. Keep it up!",
            "A flawless day. $catName might actually let you rub their belly. Exactly three times."
          ];
          return dialogues[random.nextInt(dialogues.length)];
      }

      final dialogues = [
        "Whoa, slow down! ${snapshot.stepCount} steps? Are you chasing a laser pointer?",
        "Excellent work, human. You have successfully proved you are not a complete couch potato to $catName.",
        "$catName is considering promoting you from 'staff' to 'acceptable roommate'.",
        "Look at you go! $catName is exhausted just thinking about all your steps.",
        "You crushed it today! $catName demands celebratory treats.",
        "$catName is vibrating with excitement! Or maybe they just saw a bird.",
        "Stellar performance. $catName would give you a high-five if they had thumbs.",
        "You're on fire! Not literally, because $catName hates the smell of smoke, but you get it.",
        "Today was a triumph. $catName is making a note of your huge success.",
        "$catName purrs approvingly at your ${snapshot.stepCount} steps."
      ];
      return dialogues[random.nextInt(dialogues.length)];
    } else if (tier == MoodTier.low) {
      final dialogues = [
        "A bit sluggish today. Are you saving your energy for a nap in a sunbeam, like $catName?",
        "Only ${snapshot.stepCount} steps? $catName guesses gravity was especially heavy today.",
        "$catName has seen hairballs with more motivation than you had today.",
        "Not terrible, but not great either. Kind of like that cheap kibble you bought $catName.",
        "Come on, move those two legs! The mice won't catch themselves, says $catName.",
        "$catName gives you a solid C- for effort today.",
        "You're slacking, human. $catName expects better service.",
        "Did you forget how to walk? $catName is willing to demonstrate.",
        "Tomorrow is another day to not disappoint $catName.",
        "$catName is judging you mildly from across the room."
      ];
      return dialogues[random.nextInt(dialogues.length)];
    } else if (tier == MoodTier.good) {
      final dialogues = [
        "A solid day, human! Keep this up and $catName might not knock your water glass off the table.",
        "Not bad! You're almost as active as $catName when they hear the treat bag open.",
        "Acceptable performance today. $catName shall reward you by sitting on your keyboard.",
        "Good job! Now, direct that energy toward opening a can of tuna for $catName.",
        "I'll allow it. ${snapshot.stepCount} steps is a respectable effort for a hairless ape, says $catName.",
        "$catName nods in quiet approval.",
        "You did well today. $catName considers you adequate.",
        "Almost thriving! $catName is cheering you on silently.",
        "A productive day. $catName is pleased with their human.",
        "$catName thinks you deserve a pat on the head. But they won't give it."
      ];
      return dialogues[random.nextInt(dialogues.length)];
    }
    
    final neutralDialogues = [
      "Just another balanced day. Time for $catName to stare at a wall for an hour.",
      "Utterly average. Just how $catName likes it. Now, fetch the toys.",
      "Neither zooming nor snoozing. You are the epitome of 'meh' today, says $catName.",
      "$catName has no strong feelings about today. Which means you survived.",
      "An adequate day. $catName has decided to spare your ankles. For now.",
      "Perfectly balanced, as all things should be. $catName is yawning.",
      "Nothing to report. $catName is going back to sleep.",
      "A thoroughly unremarkable day. $catName approves of the lack of chaos.",
      "You existed today. $catName acknowledges this fact.",
      "$catName is feeling incredibly neutral about your performance."
    ];
    return neutralDialogues[random.nextInt(neutralDialogues.length)];
  }

  static List<String> generateDetailedInsights(HealthSnapshot snapshot, String catName) {
    final insights = <String>[];
    final random = math.Random();
    
    // Activity Insight
    if (snapshot.stepCount < 3000) {
      final options = [
        "🐾 You've barely moved today (${snapshot.stepCount} steps). The food bowl isn't going to walk to you, human.",
        "🐾 ${snapshot.stepCount} steps? Did you just walk to the fridge and back? $catName is watching.",
        "🐾 $catName is judging your sedentary lifestyle. Get off your tail."
      ];
      insights.add(options[random.nextInt(options.length)]);
    } else if (snapshot.stepCount >= 10000) {
      final options = [
        "🐾 Amazing! ${snapshot.stepCount} steps today. Are we practicing for the zoomies Olympics?",
        "🐾 ${snapshot.stepCount} steps! You've successfully marked your territory all over town, thinks $catName.",
        "🐾 Spectacular leg movement today. You almost look majestic to $catName."
      ];
      insights.add(options[random.nextInt(options.length)]);
    } else {
      final options = [
        "🐾 A solid effort of ${snapshot.stepCount} steps. Not bad for a two-legs.",
        "🐾 ${snapshot.stepCount} steps. You're adequately active, $catName supposes.",
        "🐾 You moved around a bit. Good. Blood circulation is important for opening tuna cans for $catName."
      ];
      insights.add(options[random.nextInt(options.length)]);
    }
    
    // Screen Time Insight
    if (snapshot.screenTimeHours > targetScreenTimeHours) {
      final options = [
        "👀 You've stared at the glowing rectangle for ${snapshot.screenTimeHours.toStringAsFixed(1)} hours. $catName's eyes hurt just watching you.",
        "👀 ${snapshot.screenTimeHours.toStringAsFixed(1)} hours on the screen? Are you trying to fry your brain?",
        "👀 Put the flat glowing box down! It's been ${snapshot.screenTimeHours.toStringAsFixed(1)} hours. Look at $catName instead!"
      ];
      insights.add(options[random.nextInt(options.length)]);
    } else {
      final options = [
        "👀 Only ${snapshot.screenTimeHours.toStringAsFixed(1)} hours of screen time. Good. More time to pet $catName.",
        "👀 Sensible screen usage today (${snapshot.screenTimeHours.toStringAsFixed(1)}h). $catName approves.",
        "👀 Less time on the glowing rectangle means more time admiring $catName's fur. Excellent choice."
      ];
      insights.add(options[random.nextInt(options.length)]);
    }
    
    // Pickups/Restlessness Insight
    if (snapshot.lateNightPickups > 0) {
      final options = [
        "🌙 You picked up your phone ${snapshot.lateNightPickups} times past midnight. What, did you see a ghost or a laser?",
        "🌙 ${snapshot.lateNightPickups} late-night phone checks. Sleep is for the weak, huh?",
        "🌙 Why are you awake playing with the glowing box ${snapshot.lateNightPickups} times at night? That's $catName's zoomie time!"
      ];
      insights.add(options[random.nextInt(options.length)]);
    } else {
      final options = [
        "🌙 You actually rested without checking your phone all night. Very cat-like.",
        "🌙 No late-night phone pickups. You slept like a log. Or like $catName.",
        "🌙 Uninterrupted sleep detected. $catName is proud of you, human."
      ];
      insights.add(options[random.nextInt(options.length)]);
    }
    
    return insights;
  }
}
