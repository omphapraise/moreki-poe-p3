/// Simple in-app translations: English (en), French (fr), Afrikaans (af).
///
/// Takes a plain language code so lib/core never imports from features.
/// Unknown codes and missing keys fall back to English, then to the key.
/// French and Afrikaans are AI-drafted and need a fluent speaker's skim.
class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;

  static const List<String> codes = ['en', 'fr', 'af'];

  /// The whole table for one language (unknown code gives English).
  static Map<String, String> table(String code) => _tables[code] ?? _en;

  /// Looks up [key]. Falls back to English, then to the key itself.
  String get(String key) => table(languageCode)[key] ?? _en[key] ?? key;

  /// Looks up [key] and swaps each {name} placeholder for its value.
  String format(String key, Map<String, String> values) {
    var result = get(key);
    values.forEach((name, value) {
      result = result.replaceAll('{$name}', value);
    });
    return result;
  }

  /// Short month name, [month] is 1 to 12.
  String month(int month) => get('month.$month');
}

const Map<String, Map<String, String>> _tables = {
  'en': _en,
  'fr': _fr,
  'af': _af,
};

const Map<String, String> _en = {
  'cm.title': 'Crisis Mode',
  'cm.back': 'Back',
  'cm.intro': "Tight month? Type in what comes in and what you have to pay. Moreki shows where you stand, then a few calm steps. You've got this.",
  'cm.hero.label': 'Left after essentials',
  'cm.hero.captionNone': 'Add your income and essentials to see where you stand.',
  'cm.hero.captionNoIncome': 'Add your income to see how your essentials compare.',
  'cm.hero.captionShort': 'Your essentials are more than your income. That is okay: the steps below can help.',
  'cm.hero.captionOk': 'Your essentials take about {percent}% of your income.',
  'cm.row.income': 'Monthly income',
  'cm.row.essentials': 'Essentials',
  'cm.row.left': 'Left over',
  'cm.panel.title': 'Your monthly numbers',
  'cm.field.income': 'Income',
  'cm.field.rent': 'Rent or bond',
  'cm.field.food': 'Food',
  'cm.field.transport': 'Transport',
  'cm.field.debt': 'Debt payments',
  'cm.field.other': 'Other must-pay costs',
  'cm.save': 'Save',
  'cm.saved': 'Saved on this phone',
  'cm.err.amount': 'Use numbers only, like 250 or 12.50',
  'cm.steps.title': 'Calm steps to take',
  'cm.step1': 'Cover the essentials first: food, a roof over your head and getting to work.',
  'cm.step2': 'Talk to the people you owe early. Most would rather hear from you than hear nothing.',
  'cm.step3': 'Pause what you can live without for now, like subscriptions and takeaways.',
  'cm.step4': 'Write down every rand coming in and going out this month.',
  'cm.step5': "Tell someone you trust. You don't have to carry this alone.",
  'cm.note': 'General guidance only, not financial or legal advice. Your numbers stay on this phone.',
  'sh.title': 'Side hustle',
  'sh.back': 'Back',
  'sh.intro': 'Track what your side hustle brings in and what it costs, so you can see what you really keep.',
  'sh.hero.label': 'What you keep this month',
  'sh.hero.captionNone': 'Add income or a cost to see what you keep.',
  'sh.hero.captionKeep': 'You keep about {percent}% of what you earn this month.',
  'sh.hero.captionNoIncome': 'No income yet this month, only costs. That is normal when you are starting out.',
  'sh.hero.captionLoss': 'Costs are higher than income this month. It happens, and now you can see it.',
  'sh.row.income': 'Income this month',
  'sh.row.costs': 'Costs this month',
  'sh.row.allTime': 'Kept all time',
  'sh.panel.title': 'Add to your side hustle',
  'sh.type.income': 'Income',
  'sh.type.cost': 'Cost',
  'sh.field.amount': 'Amount',
  'sh.field.note': 'Note (optional)',
  'sh.field.noteHint': 'e.g. braai plates',
  'sh.add': 'Add',
  'sh.err.amount': 'Enter a valid amount, like 250 or 12.50',
  'sh.recent.title': 'Recent entries',
  'sh.recent.empty': 'Nothing yet. Add your first income or cost above.',
  'sh.deleted': 'Entry deleted',
  'sh.undo': 'Undo',
  'sh.deleteTooltip': 'Delete {title}, {amount}',
  'sh.note': 'This only tracks your money. It is not tax advice. This is saved on this phone.',
  'coach.back': 'Back',
  'coach.disclaimer': 'Saved answers from Moreki. Not live AI. Not financial advice.',
  'coach.loadError': "I couldn't load the saved answers.",
  'coach.retry': 'Try again',
  'coach.topics': 'Topics',
  'coach.questions': 'Questions people ask',
  'coach.related': 'Related',
  'coach.outOfDate': 'Saved answers can be out of date. Check the sources and ask a professional before big decisions.',
  'coach.hint': 'Ask a money question',
  'coach.ask': 'Ask',
  'coach.noMatch': "I don't have a saved answer for that yet. Try one of the topics below, or rephrase your question.",
  'coach.pickTopic': 'Pick a topic below and I will show you what I can answer.',
  'coach.theseTopics': 'These topics might help:',
  'coach.nextStep': 'Next step',
  'coach.sources': 'Sources',
  'coach.sourceRow': '{title} (checked {date})',
  'coach.statusOn': '{status} on {date}',
  'coach.status.verified': 'Verified',
  'coach.status.partial': 'Partly verified',
  'coach.status.unverified': 'Unverified',
  'coach.status.general': 'General guidance',
  'coach.open': 'Open',
  'coach.open.money': 'Open Money',
  'coach.open.salaryDiagnosis': 'Open Salary Diagnosis',
  'coach.open.creditScore': 'Open Credit Score',
  'coach.open.taxReturn': 'Open Tax Return',
  'coach.open.emergencyFund': 'Open Emergency Fund',
  'coach.open.familyContribution': 'Open Family Contribution',
  'coach.open.sideHustle': 'Open Side Hustle Tracker',
  'coach.open.insuranceGuide': 'Open Insurance Guide',
  'coach.open.crisisMode': 'Open Crisis Mode',
  'month.1': 'Jan',
  'month.2': 'Feb',
  'month.3': 'Mar',
  'month.4': 'Apr',
  'month.5': 'May',
  'month.6': 'Jun',
  'month.7': 'Jul',
  'month.8': 'Aug',
  'month.9': 'Sep',
  'month.10': 'Oct',
  'month.11': 'Nov',
  'month.12': 'Dec',
  'nav.home': 'Home',
  'nav.money': 'Money',
  'nav.plan': 'Plan',
  'nav.profile': 'Profile',
  'category.food': 'Food',
  'category.transport': 'Transport',
  'category.rent': 'Rent',
  'category.airtimeData': 'Airtime & data',
  'category.electricity': 'Electricity',
  'category.family': 'Family',
  'category.entertainment': 'Entertainment',
  'category.other': 'Other',
  'money.cat.food': 'Food and groceries',
  'money.cat.transport': 'Transport (taxi, bus, petrol)',
  'money.cat.rent': 'Rent',
  'money.cat.airtimeData': 'Airtime and data',
  'money.cat.electricity': 'Electricity',
  'money.cat.family': 'Family',
  'money.cat.entertainment': 'Entertainment',
  'money.cat.other': 'Other',
  'money.title': 'Your money',
  'money.left': 'Left to spend',
  'money.spentLabel': 'Spent this month',
  'money.caption': '{spent} of {budget} spent this month',
  'money.noBudgetCaption': 'Set a monthly budget to see what is left.',
  'money.view.overview': 'Overview',
  'money.view.expenses': 'Expenses',
  'money.budget.title': 'Monthly budget',
  'money.budget.current': 'Current: {amount}',
  'money.budget.notSet': 'Not set yet',
  'money.budget.field': 'Budget for this month',
  'money.budget.save': 'Save budget',
  'money.budget.error': 'Enter a valid amount, like 5000 or 5000.50',
  'money.add.title': 'Add an expense',
  'money.add.amount': 'Amount',
  'money.add.category': 'Category',
  'money.add.dateToday': 'Date: Today',
  'money.add.date': 'Date: {date}',
  'money.add.otherMonth':
      "This date is in another month, so it does not count toward this "
      "month's budget.",
  'money.add.note': 'Note (optional)',
  'money.add.noteHint': 'e.g. taxi to work',
  'money.add.button': 'Add expense',
  'money.add.error': 'Enter a valid amount, like 250 or 12.50',
  'money.recent.title': 'Recent expenses',
  'money.recent.empty': 'No expenses yet. Add your first one above.',
  'money.recent.seeAll': 'See all {n} expenses',
  'money.all.title': 'All expenses',
  'money.all.empty':
      'No expenses yet. Add your first one on the Overview tab.',
  'money.deleted': 'Expense deleted',
  'money.undo': 'Undo',
  'money.deleteTooltip': 'Delete {title}, {amount}',
  'ef.title': 'Emergency fund',
  'ef.back': 'Back',
  'ef.intro':
      'Money set aside for real emergencies, like a medical bill or a car '
      'breakdown. A sale is not an emergency.',
  'ef.badAmount': 'Enter a valid amount, like 250 or 12.50',
  'ef.essentialsZero': 'Enter your monthly essentials to set a goal',
  'ef.saved': 'Saved so far',
  'ef.goalCaption': 'of {goal} goal ({months} of essentials)',
  'ef.noGoalCaption': 'Set your monthly essentials to see your goal.',
  'ef.ringSemantics': 'Emergency fund: {percent} percent of your goal saved',
  'ef.goalReached': 'Goal reached',
  'ef.toGo': '{amount} to go',
  'ef.milestones': 'Milestones',
  'ef.ms.week': 'One week of essentials',
  'ef.ms.month': 'One month of essentials',
  'ef.ms.three': 'Three months of essentials',
  'ef.ms.six': 'Six months of essentials',
  'ef.ms.other': '{months} of essentials',
  'ef.reached': 'Reached',
  'ef.toGoShort': 'To go',
  'ef.month.one': '1 month',
  'ef.month.many': '{n} months',
  'ef.add.title': 'Add to your fund',
  'ef.add.field': 'Amount you saved',
  'ef.add.button': 'Add to fund',
  'ef.plan.title': 'Your plan',
  'ef.plan.essentials': 'Monthly essentials (rent, food, transport, bills)',
  'ef.plan.goal': 'Goal',
  'ef.plan.monthly': 'How much can you save each month? (optional)',
  'ef.plan.save': 'Save plan',
  'ef.recent.title': 'Recent savings',
  'ef.recent.empty': 'Nothing added yet. Every bit counts.',
  'ef.recent.row': 'Added to fund',
  'ef.rule':
      'A common rule of thumb is three to six months of essential costs. '
      'Your situation may differ. This is saved on this phone.',
  'ef.est.done': 'Keep it for real emergencies.',
  'ef.est.none': 'Add what you can save each month to see an estimate.',
  'ef.est.around': '(around {date})',
  'ef.est.text':
      'Estimate: at {amount} a month, about {months}{when}. Real life can '
      'change this.',
  'chart.title': 'Daily spending',
  'chart.lastDays': 'Last {n} days',
  'chart.empty':
      'No spending logged in the last {n} days. Your daily bars show up '
      'here once you log expenses.',
  'chart.semantics':
      'Daily spending bar chart for the last {n} days. Today: {amount}.',
  'chart.wd.1': 'M',
  'chart.wd.2': 'T',
  'chart.wd.3': 'W',
  'chart.wd.4': 'T',
  'chart.wd.5': 'F',
  'chart.wd.6': 'S',
  'chart.wd.7': 'S',
  'home.greeting.morning': 'Good morning',
  'home.greeting.afternoon': 'Good afternoon',
  'home.greeting.evening': 'Good evening',
  'home.payday.today': 'Payday is today',
  'home.payday.tomorrow': 'Payday is tomorrow',
  'home.payday.days': '{n} days to payday',
  'home.hero.label': 'Left to spend this month',
  'home.hero.noBudget': 'Set your monthly budget to see what you have left.',
  'home.hero.over': 'Over budget: {used}% of your {budget} used',
  'home.hero.used': '{used}% of your {budget} budget used',
  'home.view.overview': 'Overview',
  'home.view.spending': 'Spending now',
  'home.score.semUnlocked': 'Moreki Score: {score} out of 100',
  'home.score.semLocked':
      'Moreki Score locked. Log a bit more to unlock it.',
  'home.score.of': 'of 100',
  'home.score.locked': 'Locked',
  'home.score.unlockHint':
      'Log a bit more to unlock your score. Set a budget and log 3 '
      'expenses on 2 different days.',
  'home.score.explanation':
      "Your score shows how your spending is pacing against your budget "
      "and how consistently you track it. It's not a credit score.",
  'home.stat.score': 'Moreki Score',
  'home.stat.budgetUsed': 'Budget used',
  'home.stat.biggest': 'Biggest spend',
  'home.notSet': 'Not set',
  'home.nothingYet': 'Nothing yet',
  'home.bento.spent': 'Spent this month',
  'home.bento.budget': 'Monthly budget',
  'home.bento.logged': 'Expenses logged',
  'home.spending.title': 'Where it went this month',
  'home.spending.empty':
      'Nothing spent yet this month. Once you log expenses, your biggest '
      'categories show up here.',
  'home.spending.pct': '{n}% of spending',
  'home.recent.title': 'Recent activity',
  'home.recent.empty': 'No expenses yet. Your latest ones will show up here.',
  'home.next.setBudget.title': 'Set your budget',
  'home.next.setBudget.body': 'Tell Moreki what you can spend this month.',
  'home.next.setBudget.button': 'Set budget',
  'home.next.over.title': 'You are over budget by {amount}',
  'home.next.over.body':
      'It happens. Check where it went and plan the rest of the month.',
  'home.next.over.button': 'See expenses',
  'home.next.high.title': 'You have used {n}% of your budget',
  'home.next.high.body': 'Go easy on non-essentials for the rest of the month.',
  'home.next.high.button': 'See expenses',
  'home.next.log.title': 'Log an expense',
  'home.next.log.body': 'A few more entries and your Moreki Score unlocks.',
  'home.next.log.button': 'Add expense',
  'home.next.ok.title': 'You are on track',
  'home.next.ok.body': 'Keep logging so your score stays accurate.',
  'home.next.ok.button': 'Add expense',
  'plan.title': 'Plan',
  'plan.subtitle': 'Your money tools in one place.',
  'plan.open': 'Open',
  'plan.comingSoon': 'Coming soon',
  'plan.coach.title': 'Ask Moreki',
  'plan.coach.blurb': 'Saved answers to common money questions. Not live AI.',
  'plan.fund.title': 'Emergency Fund Builder',
  'plan.fund.blurb': 'Set a goal, track your savings, see your progress.',
  'plan.family.title': 'Family Contribution Calculator',
  'plan.family.blurb': 'Support your family without breaking your budget.',
  'plan.salary.title': 'Salary Diagnosis',
  'plan.salary.blurb': 'See where your pay really goes.',
  'plan.credit.title': 'Credit Score Monitoring',
  'plan.credit.blurb': 'Understand your credit and how to improve it.',
  'plan.tax.title': 'Tax Return Made Simple',
  'plan.tax.blurb': 'Get ready for tax season without the stress.',
  'plan.hustle.title': 'Side Hustle Tracker',
  'plan.hustle.blurb': 'Track extra income and what you keep.',
  'plan.cover.title': 'Funeral Cover and Medical Aid Guide',
  'plan.cover.blurb': 'Make sense of cover options.',
  'plan.crisis.title': 'Crisis Mode',
  'plan.crisis.blurb': 'A calm plan for when money gets tight.',
  'profile.title': 'Your profile',
  'profile.hi': 'Hi, {name}',
  'profile.subtitle':
      'No account needed. Everything here is saved on this phone.',
  'profile.nextPayday': 'Next payday',
  'profile.today': 'Today',
  'profile.tomorrow': 'Tomorrow',
  'profile.daysAway': '{n} days',
  'profile.aboutYou': 'About you',
  'profile.nameLabel': 'First name or nickname (optional)',
  'profile.paydayLabel': 'Payday, day of the month (optional)',
  'profile.badDay': 'Enter a day from 1 to 31',
  'profile.save': 'Save',
  'profile.saved': 'Saved on this phone',
  'profile.language': 'Language',
  'profile.languageNote':
      'Your choice is saved. Moreki works in English, French and Afrikaans. '
      'Tshivenda and siSwati are planned, but not in this version.',
  'profile.privacy': 'Privacy',
  'profile.privacyBody':
      'Your numbers stay on this phone. Moreki has no sign-in yet, does not '
      'send your data anywhere, and never moves money for you.',
  'profile.about': 'About Moreki',
  'profile.aboutBody':
      'Moreki is a money coach for first-job earners, built by Cubic Code. '
      'It gives guidance, not financial advice. Ask Moreki uses saved '
      'answers, not live AI.',
  'profile.data': 'Your data',
  'profile.dataBody':
      'Wipe your budget, expenses, emergency fund, family plan and profile '
      'from this phone.',
  'profile.deleteButton': 'Delete all my data',
  'profile.deleteTitle': 'Delete all my data?',
  'profile.deleteBody':
      "This deletes your budget, expenses, emergency fund, family plan and "
      "profile from this phone. This can't be undone.",
  'profile.cancel': 'Cancel',
  'profile.deleteEverything': 'Delete everything',
  'profile.deleted': 'All your data was deleted from this phone',
  'fam.title': 'Family contribution',
  'fam.back': 'Back',
  'fam.intro':
      'Helping your family is a good thing, and you need to be okay too. '
      'Work out an amount you can keep sending every month.',
  'fam.err.amount': 'Enter a valid amount, like 250 or 12.50',
  'fam.err.takeHome': 'Enter your monthly take-home pay',
  'fam.err.essentials': 'Enter your monthly essentials',
  'fam.v.comfortable.title': 'Comfortable',
  'fam.v.comfortable.body':
      'You can send {asked} and still cover your essentials, your savings '
      'and your personal buffer. You would have {left} left each month.',
  'fam.v.tight.title': 'Tight but possible',
  'fam.v.tight.body':
      '{asked} is possible, but it uses {shortfall} of your personal '
      'buffer. Only commit to it if you can keep it up every month.',
  'fam.v.tooMuch.title': 'Too much for now',
  'fam.v.tooMuch.bodySafe':
      '{asked} is {shortfall} more than your month can carry. A smaller '
      'steady amount, like {safe}, is easier to keep up. It is okay to '
      'talk to your family about what is realistic.',
  'fam.v.tooMuch.bodyNone':
      'Right now your essentials and savings already take most of your '
      'pay, so there is nothing safe to send. It is okay to tell your '
      'family that honestly.',
  'fam.hero.label': 'Safe to send each month',
  'fam.hero.captionNone': 'Enter your numbers to see what is safe to send.',
  'fam.hero.captionSafe':
      'About {percent}% of your take-home pay, after your essentials, '
      'savings and a personal buffer.',
  'fam.hero.captionZero':
      'Your essentials and savings already take most of your pay.',
  'fam.row.takeHome': 'Take-home pay',
  'fam.row.essentials': 'Your essentials',
  'fam.row.savings': 'Your savings',
  'fam.row.buffer': 'Personal buffer ({percent}%)',
  'fam.row.bufferSub': 'Kept for you, so you are okay too',
  'fam.row.safe': 'Safe to send',
  'fam.panel.title': 'Your numbers (per month)',
  'fam.field.takeHome': 'Take-home pay (after tax)',
  'fam.field.essentials': 'Your essentials (rent, food, transport, bills)',
  'fam.field.savings': 'Your own savings (optional)',
  'fam.field.requested': 'What your family is asking for (optional)',
  'fam.calculate': 'Calculate',
  'fam.note':
      'The {percent}% personal buffer is a rule of thumb, not a rule. Your '
      'situation may differ. This is saved on this phone. Moreki never '
      'moves money for you.',
};

const Map<String, String> _fr = {
  'cm.title': 'Mode crise',
  'cm.back': 'Retour',
  'cm.intro': "Un mois serré ? Saisis ce qui rentre et ce que tu dois payer. Moreki montre où tu en es, puis quelques étapes calmes. Tu vas y arriver.",
  'cm.hero.label': 'Reste après l’essentiel',
  'cm.hero.captionNone': 'Ajoute ton revenu et tes dépenses essentielles pour voir où tu en es.',
  'cm.hero.captionNoIncome': 'Ajoute ton revenu pour comparer avec tes dépenses essentielles.',
  'cm.hero.captionShort': 'Tes dépenses essentielles dépassent ton revenu. Ce n’est pas grave : les étapes ci-dessous peuvent aider.',
  'cm.hero.captionOk': 'Tes dépenses essentielles représentent environ {percent} % de ton revenu.',
  'cm.row.income': 'Revenu mensuel',
  'cm.row.essentials': 'Dépenses essentielles',
  'cm.row.left': 'Reste',
  'cm.panel.title': 'Tes chiffres du mois',
  'cm.field.income': 'Revenu',
  'cm.field.rent': 'Loyer ou prêt immobilier',
  'cm.field.food': 'Nourriture',
  'cm.field.transport': 'Transport',
  'cm.field.debt': 'Remboursements de dettes',
  'cm.field.other': 'Autres frais obligatoires',
  'cm.save': 'Enregistrer',
  'cm.saved': 'Enregistré sur ce téléphone',
  'cm.err.amount': 'Utilise uniquement des chiffres, comme 250 ou 12,50',
  'cm.steps.title': 'Étapes calmes à suivre',
  'cm.step1': 'Couvre d’abord l’essentiel : nourriture, un toit et le trajet pour aller travailler.',
  'cm.step2': 'Parle tôt aux personnes à qui tu dois de l’argent. La plupart préfèrent avoir de tes nouvelles plutôt que le silence.',
  'cm.step3': 'Mets en pause ce dont tu peux te passer pour l’instant, comme les abonnements et les plats à emporter.',
  'cm.step4': 'Note chaque rand qui rentre et qui sort ce mois-ci.',
  'cm.step5': 'Parles-en à quelqu’un de confiance. Tu n’as pas à porter ça seul(e).',
  'cm.note': 'Conseils généraux uniquement, pas un avis financier ou juridique. Tes chiffres restent sur ce téléphone.',
  'sh.title': "Revenus d'appoint",
  'sh.back': 'Retour',
  'sh.intro': "Note ce que ton activit\u00E9 d'appoint rapporte et ce qu'elle co\u00FBte, pour voir ce qu'il te reste vraiment.",
  'sh.hero.label': "Ce qu'il te reste ce mois-ci",
  'sh.hero.captionNone': "Ajoute un revenu ou un co\u00FBt pour voir ce qu'il te reste.",
  'sh.hero.captionKeep': 'Tu gardes environ {percent} % de ce que tu gagnes ce mois-ci.',
  'sh.hero.captionNoIncome': "Pas encore de revenu ce mois-ci, seulement des co\u00FBts. C'est normal quand on d\u00E9marre.",
  'sh.hero.captionLoss': "Les co\u00FBts d\u00E9passent les revenus ce mois-ci. \u00C7a arrive, et maintenant tu le vois.",
  'sh.row.income': 'Revenus ce mois-ci',
  'sh.row.costs': 'Co\u00FBts ce mois-ci',
  'sh.row.allTime': 'Gard\u00E9 au total',
  'sh.panel.title': "Ajoute \u00E0 ton activit\u00E9 d'appoint",
  'sh.type.income': 'Revenu',
  'sh.type.cost': 'Co\u00FBt',
  'sh.field.amount': 'Montant',
  'sh.field.note': 'Note (facultatif)',
  'sh.field.noteHint': 'p. ex. assiettes de braai',
  'sh.add': 'Ajouter',
  'sh.err.amount': 'Entre un montant valide, comme 250 ou 12.50',
  'sh.recent.title': 'Entr\u00E9es r\u00E9centes',
  'sh.recent.empty': "Rien pour l'instant. Ajoute ton premier revenu ou co\u00FBt ci-dessus.",
  'sh.deleted': 'Entr\u00E9e supprim\u00E9e',
  'sh.undo': 'Annuler',
  'sh.deleteTooltip': 'Supprimer {title}, {amount}',
  'sh.note': "Cela suit seulement ton argent. Ce n'est pas un conseil fiscal. Tout est enregistr\u00E9 sur ce t\u00E9l\u00E9phone.",
  'coach.back': 'Retour',
  'coach.disclaimer': 'R\u00E9ponses enregistr\u00E9es de Moreki. Pas une IA en direct. Pas un conseil financier.',
  'coach.loadError': "Je n'ai pas pu charger les r\u00E9ponses enregistr\u00E9es.",
  'coach.retry': 'R\u00E9essayer',
  'coach.topics': 'Sujets',
  'coach.questions': 'Questions fr\u00E9quentes',
  'coach.related': 'Voir aussi',
  'coach.outOfDate': "Les r\u00E9ponses enregistr\u00E9es peuvent \u00EAtre d\u00E9pass\u00E9es. V\u00E9rifie les sources et demande l'avis d'un professionnel avant les grandes d\u00E9cisions.",
  'coach.hint': "Pose une question sur l'argent",
  'coach.ask': 'Demander',
  'coach.noMatch': "Je n'ai pas encore de r\u00E9ponse enregistr\u00E9e pour \u00E7a. Essaie un des sujets ci-dessous, ou reformule ta question.",
  'coach.pickTopic': 'Choisis un sujet ci-dessous et je te montre ce que je peux r\u00E9pondre.',
  'coach.theseTopics': "Ces sujets pourraient t'aider :",
  'coach.nextStep': '\u00C9tape suivante',
  'coach.sources': 'Sources',
  'coach.sourceRow': '{title} (v\u00E9rifi\u00E9 le {date})',
  'coach.statusOn': '{status} le {date}',
  'coach.status.verified': 'V\u00E9rifi\u00E9',
  'coach.status.partial': 'Partiellement v\u00E9rifi\u00E9',
  'coach.status.unverified': 'Non v\u00E9rifi\u00E9',
  'coach.status.general': 'Conseil g\u00E9n\u00E9ral',
  'coach.open': 'Ouvrir',
  'coach.open.money': 'Ouvrir Argent',
  'coach.open.salaryDiagnosis': 'Ouvrir le diagnostic de salaire',
  'coach.open.creditScore': 'Ouvrir le score de cr\u00E9dit',
  'coach.open.taxReturn': "Ouvrir la d\u00E9claration d'imp\u00F4ts",
  'coach.open.emergencyFund': "Ouvrir le fonds d'urgence",
  'coach.open.familyContribution': 'Ouvrir la contribution familiale',
  'coach.open.sideHustle': "Ouvrir le suivi des revenus d'appoint",
  'coach.open.insuranceGuide': "Ouvrir le guide d'assurance",
  'coach.open.crisisMode': 'Ouvrir le mode crise',
  'month.1': 'janv.',
  'month.2': 'f\u00E9vr.',
  'month.3': 'mars',
  'month.4': 'avr.',
  'month.5': 'mai',
  'month.6': 'juin',
  'month.7': 'juil.',
  'month.8': 'ao\u00FBt',
  'month.9': 'sept.',
  'month.10': 'oct.',
  'month.11': 'nov.',
  'month.12': 'd\u00E9c.',
  'nav.home': 'Accueil',
  'nav.money': 'Argent',
  'nav.plan': 'Plan',
  'nav.profile': 'Profil',
  'category.food': 'Alimentation',
  'category.transport': 'Transport',
  'category.rent': 'Loyer',
  'category.airtimeData': 'Cr\u00E9dit t\u00E9l\u00E9phone et data',
  'category.electricity': '\u00C9lectricit\u00E9',
  'category.family': 'Famille',
  'category.entertainment': 'Loisirs',
  'category.other': 'Autre',
  'money.cat.food': 'Alimentation et courses',
  'money.cat.transport': 'Transport (taxi, bus, essence)',
  'money.cat.rent': 'Loyer',
  'money.cat.airtimeData': 'Cr\u00E9dit t\u00E9l\u00E9phone et data',
  'money.cat.electricity': '\u00C9lectricit\u00E9',
  'money.cat.family': 'Famille',
  'money.cat.entertainment': 'Loisirs',
  'money.cat.other': 'Autre',
  'money.title': 'Ton argent',
  'money.left': 'Il te reste \u00E0 d\u00E9penser',
  'money.spentLabel': 'D\u00E9pens\u00E9 ce mois-ci',
  'money.caption': '{spent} d\u00E9pens\u00E9s sur {budget} ce mois-ci',
  'money.noBudgetCaption':
      "Fixe un budget mensuel pour voir ce qu'il te reste.",
  'money.view.overview': 'Aper\u00E7u',
  'money.view.expenses': 'D\u00E9penses',
  'money.budget.title': 'Budget mensuel',
  'money.budget.current': 'Actuel : {amount}',
  'money.budget.notSet': 'Pas encore fix\u00E9',
  'money.budget.field': 'Budget pour ce mois-ci',
  'money.budget.save': 'Enregistrer le budget',
  'money.budget.error':
      'Entre un montant valide, comme 5000 ou 5000.50',
  'money.add.title': 'Ajouter une d\u00E9pense',
  'money.add.amount': 'Montant',
  'money.add.category': 'Cat\u00E9gorie',
  'money.add.dateToday': "Date : aujourd'hui",
  'money.add.date': 'Date : {date}',
  'money.add.otherMonth':
      "Cette date est dans un autre mois, donc elle ne compte pas dans le "
      "budget de ce mois-ci.",
  'money.add.note': 'Note (facultatif)',
  'money.add.noteHint': 'p. ex. taxi pour aller au travail',
  'money.add.button': 'Ajouter la d\u00E9pense',
  'money.add.error': 'Entre un montant valide, comme 250 ou 12.50',
  'money.recent.title': 'D\u00E9penses r\u00E9centes',
  'money.recent.empty':
      'Pas encore de d\u00E9penses. Ajoute la premi\u00E8re ci-dessus.',
  'money.recent.seeAll': 'Voir les {n} d\u00E9penses',
  'money.all.title': 'Toutes les d\u00E9penses',
  'money.all.empty':
      "Pas encore de d\u00E9penses. Ajoute la premi\u00E8re dans l'onglet "
      "Aper\u00E7u.",
  'money.deleted': 'D\u00E9pense supprim\u00E9e',
  'money.undo': 'Annuler',
  'money.deleteTooltip': 'Supprimer {title}, {amount}',
  'ef.title': "Fonds d'urgence",
  'ef.back': 'Retour',
  'ef.intro':
      "De l'argent mis de c\u00F4t\u00E9 pour de vraies urgences, comme une "
      "facture m\u00E9dicale ou une panne de voiture. Une promo n'est pas "
      "une urgence.",
  'ef.badAmount': 'Entre un montant valide, comme 250 ou 12.50',
  'ef.essentialsZero':
      'Entre tes d\u00E9penses essentielles mensuelles pour fixer un objectif',
  'ef.saved': '\u00C9conomis\u00E9 jusqu\'ici',
  'ef.goalCaption':
      "sur un objectif de {goal} ({months} de d\u00E9penses essentielles)",
  'ef.noGoalCaption':
      'Entre tes d\u00E9penses essentielles mensuelles pour voir ton '
      'objectif.',
  'ef.ringSemantics':
      "Fonds d'urgence : {percent} pour cent de ton objectif \u00E9conomis\u00E9",
  'ef.goalReached': 'Objectif atteint',
  'ef.toGo': 'Encore {amount}',
  'ef.milestones': '\u00C9tapes',
  'ef.ms.week': 'Une semaine de d\u00E9penses essentielles',
  'ef.ms.month': 'Un mois de d\u00E9penses essentielles',
  'ef.ms.three': 'Trois mois de d\u00E9penses essentielles',
  'ef.ms.six': 'Six mois de d\u00E9penses essentielles',
  'ef.ms.other': '{months} de d\u00E9penses essentielles',
  'ef.reached': 'Atteint',
  'ef.toGoShort': '\u00C0 venir',
  'ef.month.one': '1 mois',
  'ef.month.many': '{n} mois',
  'ef.add.title': 'Ajouter \u00E0 ton fonds',
  'ef.add.field': 'Montant \u00E9conomis\u00E9',
  'ef.add.button': 'Ajouter au fonds',
  'ef.plan.title': 'Ton plan',
  'ef.plan.essentials':
      'D\u00E9penses essentielles mensuelles (loyer, nourriture, transport, '
      'factures)',
  'ef.plan.goal': 'Objectif',
  'ef.plan.monthly':
      'Combien peux-tu \u00E9conomiser chaque mois ? (facultatif)',
  'ef.plan.save': 'Enregistrer le plan',
  'ef.recent.title': '\u00C9conomies r\u00E9centes',
  'ef.recent.empty': "Rien d'ajout\u00E9 pour l'instant. Chaque rand compte.",
  'ef.recent.row': 'Ajout\u00E9 au fonds',
  'ef.rule':
      "Une r\u00E8gle courante : trois \u00E0 six mois de d\u00E9penses "
      "essentielles. Ta situation peut \u00EAtre diff\u00E9rente. Tout est "
      "enregistr\u00E9 sur ce t\u00E9l\u00E9phone.",
  'ef.est.done': 'Garde-le pour de vraies urgences.',
  'ef.est.none':
      "Ajoute ce que tu peux \u00E9conomiser chaque mois pour voir une "
      "estimation.",
  'ef.est.around': '(vers {date})',
  'ef.est.text':
      "Estimation : avec {amount} par mois, environ {months}{when}. La vraie "
      "vie peut changer \u00E7a.",
  'chart.title': 'D\u00E9penses par jour',
  'chart.lastDays': 'Les {n} derniers jours',
  'chart.empty':
      'Aucune d\u00E9pense not\u00E9e ces {n} derniers jours. Tes barres '
      'quotidiennes appara\u00EEtront ici d\u00E8s que tu noteras des '
      'd\u00E9penses.',
  'chart.semantics':
      "Diagramme en barres des d\u00E9penses quotidiennes des {n} derniers "
      "jours. Aujourd'hui : {amount}.",
  'chart.wd.1': 'L',
  'chart.wd.2': 'M',
  'chart.wd.3': 'M',
  'chart.wd.4': 'J',
  'chart.wd.5': 'V',
  'chart.wd.6': 'S',
  'chart.wd.7': 'D',
  'home.greeting.morning': 'Bonjour',
  'home.greeting.afternoon': 'Bon apr\u00E8s-midi',
  'home.greeting.evening': 'Bonsoir',
  'home.payday.today': "La paie, c'est aujourd'hui",
  'home.payday.tomorrow': "La paie, c'est demain",
  'home.payday.days': '{n} jours avant la paie',
  'home.hero.label': 'Il te reste \u00E0 d\u00E9penser ce mois-ci',
  'home.hero.noBudget':
      "Fixe ton budget mensuel pour voir ce qu'il te reste.",
  'home.hero.over':
      'Budget d\u00E9pass\u00E9 : {used} % de tes {budget} utilis\u00E9s',
  'home.hero.used': '{used} % de ton budget de {budget} utilis\u00E9',
  'home.view.overview': 'Aper\u00E7u',
  'home.view.spending': 'D\u00E9penses actuelles',
  'home.score.semUnlocked': 'Score Moreki : {score} sur 100',
  'home.score.semLocked':
      'Score Moreki verrouill\u00E9. Note encore quelques d\u00E9penses '
      'pour le d\u00E9bloquer.',
  'home.score.of': 'sur 100',
  'home.score.locked': 'Verrouill\u00E9',
  'home.score.unlockHint':
      'Note encore quelques d\u00E9penses pour d\u00E9bloquer ton score. '
      'Fixe un budget et note 3 d\u00E9penses sur 2 jours diff\u00E9rents.',
  'home.score.explanation':
      "Ton score montre si tes d\u00E9penses suivent le rythme de ton "
      "budget et \u00E0 quel point tu les notes r\u00E9guli\u00E8rement. "
      "Ce n'est pas un score de cr\u00E9dit.",
  'home.stat.score': 'Score Moreki',
  'home.stat.budgetUsed': 'Budget utilis\u00E9',
  'home.stat.biggest': 'Plus grosse d\u00E9pense',
  'home.notSet': 'Non d\u00E9fini',
  'home.nothingYet': "Rien pour l'instant",
  'home.bento.spent': 'D\u00E9pens\u00E9 ce mois-ci',
  'home.bento.budget': 'Budget mensuel',
  'home.bento.logged': 'D\u00E9penses not\u00E9es',
  'home.spending.title': 'O\u00F9 est parti ton argent ce mois-ci',
  'home.spending.empty':
      "Rien d\u00E9pens\u00E9 pour l'instant ce mois-ci. Quand tu noteras "
      "des d\u00E9penses, tes plus grosses cat\u00E9gories appara\u00EEtront "
      "ici.",
  'home.spending.pct': '{n} % des d\u00E9penses',
  'home.recent.title': 'Activit\u00E9 r\u00E9cente',
  'home.recent.empty':
      "Pas encore de d\u00E9penses. Les derni\u00E8res appara\u00EEtront ici.",
  'home.next.setBudget.title': 'Fixe ton budget',
  'home.next.setBudget.body':
      "Dis \u00E0 Moreki ce que tu peux d\u00E9penser ce mois-ci.",
  'home.next.setBudget.button': 'Fixer le budget',
  'home.next.over.title': 'Tu d\u00E9passes ton budget de {amount}',
  'home.next.over.body':
      "\u00C7a arrive. Regarde o\u00F9 \u00E7a est parti et planifie le "
      "reste du mois.",
  'home.next.over.button': 'Voir les d\u00E9penses',
  'home.next.high.title': 'Tu as utilis\u00E9 {n} % de ton budget',
  'home.next.high.body':
      "Vas-y doucement sur le non essentiel jusqu'\u00E0 la fin du mois.",
  'home.next.high.button': 'Voir les d\u00E9penses',
  'home.next.log.title': 'Note une d\u00E9pense',
  'home.next.log.body':
      'Encore quelques entr\u00E9es et ton score Moreki se d\u00E9bloque.',
  'home.next.log.button': 'Ajouter une d\u00E9pense',
  'home.next.ok.title': 'Tu es sur la bonne voie',
  'home.next.ok.body': 'Continue \u00E0 noter pour que ton score reste juste.',
  'home.next.ok.button': 'Ajouter une d\u00E9pense',
  'plan.title': 'Plan',
  'plan.subtitle': "Tous tes outils d'argent au m\u00EAme endroit.",
  'plan.open': 'Ouvrir',
  'plan.comingSoon': 'Bient\u00F4t',
  'plan.coach.title': 'Ask Moreki',
  'plan.coach.blurb':
      "R\u00E9ponses enregistr\u00E9es aux questions d'argent courantes. "
      "Pas une IA en direct.",
  'plan.fund.title': "Constructeur de fonds d'urgence",
  'plan.fund.blurb':
      'Fixe un objectif, suis tes \u00E9conomies, vois ta progression.',
  'plan.family.title': 'Calculateur de contribution familiale',
  'plan.family.blurb':
      'Soutiens ta famille sans d\u00E9passer ton budget.',
  'plan.salary.title': 'Diagnostic de salaire',
  'plan.salary.blurb': 'Vois o\u00F9 va vraiment ta paie.',
  'plan.credit.title': 'Suivi du score de cr\u00E9dit',
  'plan.credit.blurb':
      "Comprends ton cr\u00E9dit et comment l'am\u00E9liorer.",
  'plan.tax.title': "D\u00E9claration d'imp\u00F4ts simplifi\u00E9e",
  'plan.tax.blurb':
      "Pr\u00E9pare-toi \u00E0 la saison des imp\u00F4ts sans stress.",
  'plan.hustle.title': "Suivi des revenus d'appoint",
  'plan.hustle.blurb':
      "Suis tes revenus en plus et ce qu'il te reste.",
  'plan.cover.title': 'Guide assurance obs\u00E8ques et aide m\u00E9dicale',
  'plan.cover.blurb': 'Comprends les options de couverture.',
  'plan.crisis.title': 'Mode crise',
  'plan.crisis.blurb': "Un plan calme quand l'argent se resserre.",
  'profile.title': 'Ton profil',
  'profile.hi': 'Salut, {name}',
  'profile.subtitle':
      'Pas besoin de compte. Tout est enregistr\u00E9 sur ce t\u00E9l\u00E9phone.',
  'profile.nextPayday': 'Prochaine paie',
  'profile.today': "Aujourd'hui",
  'profile.tomorrow': 'Demain',
  'profile.daysAway': '{n} jours',
  'profile.aboutYou': '\u00C0 propos de toi',
  'profile.nameLabel': 'Pr\u00E9nom ou surnom (facultatif)',
  'profile.paydayLabel': 'Jour de paie, jour du mois (facultatif)',
  'profile.badDay': 'Entre un jour de 1 \u00E0 31',
  'profile.save': 'Enregistrer',
  'profile.saved': 'Enregistr\u00E9 sur ce t\u00E9l\u00E9phone',
  'profile.language': 'Langue',
  'profile.languageNote':
      'Ton choix est enregistr\u00E9. Moreki fonctionne en anglais, en '
      'fran\u00E7ais et en afrikaans. Le tshivenda et le siSwati sont '
      'pr\u00E9vus, mais pas dans cette version.',
  'profile.privacy': 'Confidentialit\u00E9',
  'profile.privacyBody':
      "Tes chiffres restent sur ce t\u00E9l\u00E9phone. Moreki n'a pas encore "
      "de connexion, n'envoie tes donn\u00E9es nulle part et ne d\u00E9place "
      "jamais d'argent \u00E0 ta place.",
  'profile.about': '\u00C0 propos de Moreki',
  'profile.aboutBody':
      "Moreki est un coach d'argent pour ceux qui d\u00E9crochent leur "
      "premier emploi, cr\u00E9\u00E9 par Cubic Code. Il donne des conseils, "
      "pas des conseils financiers professionnels. Ask Moreki utilise des "
      "r\u00E9ponses enregistr\u00E9es, pas une IA en direct.",
  'profile.data': 'Tes donn\u00E9es',
  'profile.dataBody':
      "Efface ton budget, tes d\u00E9penses, ton fonds d'urgence, ton plan "
      "familial et ton profil de ce t\u00E9l\u00E9phone.",
  'profile.deleteButton': 'Supprimer toutes mes donn\u00E9es',
  'profile.deleteTitle': 'Supprimer toutes mes donn\u00E9es ?',
  'profile.deleteBody':
      "Cela supprime ton budget, tes d\u00E9penses, ton fonds d'urgence, ton "
      "plan familial et ton profil de ce t\u00E9l\u00E9phone. "
      "C'est irr\u00E9versible.",
  'profile.cancel': 'Annuler',
  'profile.deleteEverything': 'Tout supprimer',
  'profile.deleted':
      'Toutes tes donn\u00E9es ont \u00E9t\u00E9 supprim\u00E9es de ce '
      't\u00E9l\u00E9phone',
  'fam.title': 'Contribution familiale',
  'fam.back': 'Retour',
  'fam.intro':
      "Aider ta famille, c'est bien, et tu dois aussi aller bien. Trouve "
      "un montant que tu peux continuer \u00E0 envoyer chaque mois.",
  'fam.err.amount': 'Entre un montant valide, comme 250 ou 12.50',
  'fam.err.takeHome': 'Entre ton salaire net mensuel',
  'fam.err.essentials': 'Entre tes d\u00E9penses essentielles mensuelles',
  'fam.v.comfortable.title': 'Confortable',
  'fam.v.comfortable.body':
      'Tu peux envoyer {asked} et couvrir quand m\u00EAme tes d\u00E9penses '
      'essentielles, tes \u00E9conomies et ta r\u00E9serve personnelle. '
      'Il te resterait {left} chaque mois.',
  'fam.v.tight.title': 'Serr\u00E9 mais possible',
  'fam.v.tight.body':
      "{asked}, c'est possible, mais \u00E7a utilise {shortfall} de ta "
      "r\u00E9serve personnelle. Engage-toi seulement si tu peux tenir "
      "chaque mois.",
  'fam.v.tooMuch.title': "Trop pour l'instant",
  'fam.v.tooMuch.bodySafe':
      "{asked}, c'est {shortfall} de plus que ce que ton mois peut "
      "supporter. Un montant plus petit mais r\u00E9gulier, comme {safe}, "
      "est plus facile \u00E0 tenir. Tu peux parler avec ta famille de ce "
      "qui est r\u00E9aliste.",
  'fam.v.tooMuch.bodyNone':
      "Pour l'instant, tes d\u00E9penses essentielles et tes "
      "\u00E9conomies prennent d\u00E9j\u00E0 presque tout ton salaire, "
      "donc il n'y a rien \u00E0 envoyer sans risque. Tu peux le dire "
      "honn\u00EAtement \u00E0 ta famille.",
  'fam.hero.label': 'Montant s\u00FBr \u00E0 envoyer chaque mois',
  'fam.hero.captionNone':
      'Entre tes chiffres pour voir ce que tu peux envoyer sans risque.',
  'fam.hero.captionSafe':
      'Environ {percent} % de ton salaire net, apr\u00E8s tes d\u00E9penses '
      'essentielles, tes \u00E9conomies et une r\u00E9serve personnelle.',
  'fam.hero.captionZero':
      'Tes d\u00E9penses essentielles et tes \u00E9conomies prennent '
      'd\u00E9j\u00E0 presque tout ton salaire.',
  'fam.row.takeHome': 'Salaire net',
  'fam.row.essentials': 'Tes d\u00E9penses essentielles',
  'fam.row.savings': 'Tes \u00E9conomies',
  'fam.row.buffer': 'R\u00E9serve personnelle ({percent} %)',
  'fam.row.bufferSub': 'Gard\u00E9e pour toi, pour que tu ailles bien aussi',
  'fam.row.safe': 'Montant s\u00FBr \u00E0 envoyer',
  'fam.panel.title': 'Tes chiffres (par mois)',
  'fam.field.takeHome': 'Salaire net (apr\u00E8s imp\u00F4ts)',
  'fam.field.essentials':
      'Tes d\u00E9penses essentielles (loyer, nourriture, transport, '
      'factures)',
  'fam.field.savings': 'Tes propres \u00E9conomies (facultatif)',
  'fam.field.requested': 'Ce que ta famille demande (facultatif)',
  'fam.calculate': 'Calculer',
  'fam.note':
      "La r\u00E9serve personnelle de {percent} % est une r\u00E8gle "
      "g\u00E9n\u00E9rale, pas une r\u00E8gle stricte. Ta situation peut "
      "\u00EAtre diff\u00E9rente. Tout est enregistr\u00E9 sur ce "
      "t\u00E9l\u00E9phone. Moreki ne d\u00E9place jamais d'argent "
      "\u00E0 ta place.",
};

const Map<String, String> _af = {
  'cm.title': 'Krisismodus',
  'cm.back': 'Terug',
  'cm.intro': "Krap maand? Tik in wat inkom en wat jy moet betaal. Moreki wys waar jy staan, en dan 'n paar kalm stappe. Jy kan dit doen.",
  'cm.hero.label': 'Oor ná noodsaaklike uitgawes',
  'cm.hero.captionNone': 'Voeg jou inkomste en noodsaaklike uitgawes by om te sien waar jy staan.',
  'cm.hero.captionNoIncome': 'Voeg jou inkomste by om jou noodsaaklike uitgawes te vergelyk.',
  'cm.hero.captionShort': 'Jou noodsaaklike uitgawes is meer as jou inkomste. Dis oukei: die stappe hieronder kan help.',
  'cm.hero.captionOk': 'Jou noodsaaklike uitgawes neem ongeveer {percent}% van jou inkomste.',
  'cm.row.income': 'Maandelikse inkomste',
  'cm.row.essentials': 'Noodsaaklike uitgawes',
  'cm.row.left': 'Oor',
  'cm.panel.title': 'Jou maandsyfers',
  'cm.field.income': 'Inkomste',
  'cm.field.rent': 'Huur of verband',
  'cm.field.food': 'Kos',
  'cm.field.transport': 'Vervoer',
  'cm.field.debt': 'Skuldbetalings',
  'cm.field.other': 'Ander verpligte koste',
  'cm.save': 'Stoor',
  'cm.saved': 'Op hierdie foon gestoor',
  'cm.err.amount': 'Gebruik net syfers, soos 250 of 12,50',
  'cm.steps.title': 'Kalm stappe om te neem',
  'cm.step1': 'Dek eers die noodsaaklike dinge: kos, ’n dak oor jou kop en om by die werk uit te kom.',
  'cm.step2': 'Praat vroeg met die mense aan wie jy skuld. Die meeste hoor liewer van jou as om niks te hoor nie.',
  'cm.step3': 'Sit op hou wat jy sonder kan klaarkom, soos intekeninge en wegneemetes.',
  'cm.step4': 'Skryf elke rand neer wat hierdie maand inkom en uitgaan.',
  'cm.step5': 'Sê vir iemand wat jy vertrou. Jy hoef dit nie alleen te dra nie.',
  'cm.note': 'Algemene leiding net, nie finansiële of regsadvies nie. Jou syfers bly op hierdie foon.',
  'sh.title': 'Kantwerk',
  'sh.back': 'Terug',
  'sh.intro': 'Hou by wat jou kantwerk inbring en wat dit kos, sodat jy kan sien wat jy regtig behou.',
  'sh.hero.label': 'Wat jy hierdie maand behou',
  'sh.hero.captionNone': "Voeg inkomste of 'n koste by om te sien wat jy behou.",
  'sh.hero.captionKeep': 'Jy behou ongeveer {percent}% van wat jy hierdie maand verdien.',
  'sh.hero.captionNoIncome': 'Nog geen inkomste hierdie maand nie, net koste. Dit is normaal wanneer jy begin.',
  'sh.hero.captionLoss': 'Koste is hierdie maand ho\u00EBr as inkomste. Dit gebeur, en nou kan jy dit sien.',
  'sh.row.income': 'Inkomste hierdie maand',
  'sh.row.costs': 'Koste hierdie maand',
  'sh.row.allTime': 'Altesaam behou',
  'sh.panel.title': 'Voeg by jou kantwerk',
  'sh.type.income': 'Inkomste',
  'sh.type.cost': 'Koste',
  'sh.field.amount': 'Bedrag',
  'sh.field.note': 'Nota (opsioneel)',
  'sh.field.noteHint': 'bv. braai-borde',
  'sh.add': 'Voeg by',
  'sh.err.amount': "Voer 'n geldige bedrag in, soos 250 of 12.50",
  'sh.recent.title': 'Onlangse inskrywings',
  'sh.recent.empty': 'Nog niks nie. Voeg jou eerste inkomste of koste hierbo by.',
  'sh.deleted': 'Inskrywing uitgevee',
  'sh.undo': 'Ontdoen',
  'sh.deleteTooltip': 'Vee {title}, {amount} uit',
  'sh.note': 'Dit hou net jou geld dop. Dit is nie belastingadvies nie. Dit word op hierdie foon gestoor.',
  'coach.back': 'Terug',
  'coach.disclaimer': 'Gestoorde antwoorde van Moreki. Nie lewendige KI nie. Nie finansi\u00EBle advies nie.',
  'coach.loadError': 'Ek kon nie die gestoorde antwoorde laai nie.',
  'coach.retry': 'Probeer weer',
  'coach.topics': 'Onderwerpe',
  'coach.questions': 'Vrae wat mense vra',
  'coach.related': 'Verwant',
  'coach.outOfDate': "Gestoorde antwoorde kan verouderd wees. Kontroleer die bronne en vra 'n professionele persoon voor groot besluite.",
  'coach.hint': "Vra 'n geldvraag",
  'coach.ask': 'Vra',
  'coach.noMatch': "Ek het nog nie 'n gestoorde antwoord daarop nie. Probeer een van die onderwerpe hieronder, of herformuleer jou vraag.",
  'coach.pickTopic': "Kies 'n onderwerp hieronder en ek wys jou wat ek kan beantwoord.",
  'coach.theseTopics': 'Hierdie onderwerpe kan help:',
  'coach.nextStep': 'Volgende stap',
  'coach.sources': 'Bronne',
  'coach.sourceRow': '{title} (nagegaan {date})',
  'coach.statusOn': '{status} op {date}',
  'coach.status.verified': 'Geverifieer',
  'coach.status.partial': 'Gedeeltelik geverifieer',
  'coach.status.unverified': 'Ongeverifieer',
  'coach.status.general': 'Algemene leiding',
  'coach.open': 'Maak oop',
  'coach.open.money': 'Maak Geld oop',
  'coach.open.salaryDiagnosis': 'Maak Salarisdiagnose oop',
  'coach.open.creditScore': 'Maak Krediettelling oop',
  'coach.open.taxReturn': 'Maak Belastingopgawe oop',
  'coach.open.emergencyFund': 'Maak Noodfonds oop',
  'coach.open.familyContribution': 'Maak Gesinsbydrae oop',
  'coach.open.sideHustle': 'Maak Kantwerk-opspoorder oop',
  'coach.open.insuranceGuide': 'Maak Versekeringsgids oop',
  'coach.open.crisisMode': 'Maak Krisismodus oop',
  'month.1': 'Jan',
  'month.2': 'Feb',
  'month.3': 'Mar',
  'month.4': 'Apr',
  'month.5': 'Mei',
  'month.6': 'Jun',
  'month.7': 'Jul',
  'month.8': 'Aug',
  'month.9': 'Sep',
  'month.10': 'Okt',
  'month.11': 'Nov',
  'month.12': 'Des',
  'nav.home': 'Tuis',
  'nav.money': 'Geld',
  'nav.plan': 'Plan',
  'nav.profile': 'Profiel',
  'category.food': 'Kos',
  'category.transport': 'Vervoer',
  'category.rent': 'Huur',
  'category.airtimeData': 'Lugtyd en data',
  'category.electricity': 'Elektrisiteit',
  'category.family': 'Gesin',
  'category.entertainment': 'Vermaak',
  'category.other': 'Ander',
  'money.cat.food': 'Kos en kruideniersware',
  'money.cat.transport': 'Vervoer (taxi, bus, petrol)',
  'money.cat.rent': 'Huur',
  'money.cat.airtimeData': 'Lugtyd en data',
  'money.cat.electricity': 'Elektrisiteit',
  'money.cat.family': 'Gesin',
  'money.cat.entertainment': 'Vermaak',
  'money.cat.other': 'Ander',
  'money.title': 'Jou geld',
  'money.left': 'Oor om te spandeer',
  'money.spentLabel': 'Bestee hierdie maand',
  'money.caption': '{spent} van {budget} hierdie maand bestee',
  'money.noBudgetCaption':
      "Stel 'n maandelikse begroting om te sien wat oor is.",
  'money.view.overview': 'Oorsig',
  'money.view.expenses': 'Uitgawes',
  'money.budget.title': 'Maandelikse begroting',
  'money.budget.current': 'Huidig: {amount}',
  'money.budget.notSet': 'Nog nie gestel nie',
  'money.budget.field': 'Begroting vir hierdie maand',
  'money.budget.save': 'Stoor begroting',
  'money.budget.error': "Voer 'n geldige bedrag in, soos 5000 of 5000.50",
  'money.add.title': "Voeg 'n uitgawe by",
  'money.add.amount': 'Bedrag',
  'money.add.category': 'Kategorie',
  'money.add.dateToday': 'Datum: Vandag',
  'money.add.date': 'Datum: {date}',
  'money.add.otherMonth':
      "Hierdie datum is in 'n ander maand, so dit tel nie by hierdie maand "
      "se begroting nie.",
  'money.add.note': 'Nota (opsioneel)',
  'money.add.noteHint': 'bv. taxi werk toe',
  'money.add.button': 'Voeg uitgawe by',
  'money.add.error': "Voer 'n geldige bedrag in, soos 250 of 12.50",
  'money.recent.title': 'Onlangse uitgawes',
  'money.recent.empty': 'Nog geen uitgawes nie. Voeg jou eerste een hierbo by.',
  'money.recent.seeAll': 'Sien al {n} uitgawes',
  'money.all.title': 'Alle uitgawes',
  'money.all.empty':
      'Nog geen uitgawes nie. Voeg jou eerste een op die Oorsig-oortjie by.',
  'money.deleted': 'Uitgawe uitgevee',
  'money.undo': 'Ontdoen',
  'money.deleteTooltip': 'Vee {title}, {amount} uit',
  'ef.title': 'Noodfonds',
  'ef.back': 'Terug',
  'ef.intro':
      "Geld wat opsy gesit word vir egte noodgevalle, soos 'n mediese rekening "
      "of 'n motorbreekdown. 'n Uitverkoping is nie 'n noodgeval nie.",
  'ef.badAmount': "Voer 'n geldige bedrag in, soos 250 of 12.50",
  'ef.essentialsZero':
      "Voer jou maandelikse noodsaaklike uitgawes in om 'n doel te stel",
  'ef.saved': 'Tot nou gespaar',
  'ef.goalCaption':
      "van 'n doel van {goal} ({months} se noodsaaklike uitgawes)",
  'ef.noGoalCaption':
      'Voer jou maandelikse noodsaaklike uitgawes in om jou doel te sien.',
  'ef.ringSemantics': 'Noodfonds: {percent} persent van jou doel gespaar',
  'ef.goalReached': 'Doel bereik',
  'ef.toGo': '{amount} om te gaan',
  'ef.milestones': 'Mylpale',
  'ef.ms.week': 'Een week se noodsaaklike uitgawes',
  'ef.ms.month': 'Een maand se noodsaaklike uitgawes',
  'ef.ms.three': 'Drie maande se noodsaaklike uitgawes',
  'ef.ms.six': 'Ses maande se noodsaaklike uitgawes',
  'ef.ms.other': '{months} se noodsaaklike uitgawes',
  'ef.reached': 'Bereik',
  'ef.toGoShort': 'Om te gaan',
  'ef.month.one': '1 maand',
  'ef.month.many': '{n} maande',
  'ef.add.title': 'Voeg by jou fonds',
  'ef.add.field': 'Bedrag wat jy gespaar het',
  'ef.add.button': 'Voeg by fonds',
  'ef.plan.title': 'Jou plan',
  'ef.plan.essentials':
      'Maandelikse noodsaaklike uitgawes (huur, kos, vervoer, rekenings)',
  'ef.plan.goal': 'Doel',
  'ef.plan.monthly': 'Hoeveel kan jy elke maand spaar? (opsioneel)',
  'ef.plan.save': 'Stoor plan',
  'ef.recent.title': 'Onlangse spaargeld',
  'ef.recent.empty': 'Nog niks bygevoeg nie. Elke bietjie tel.',
  'ef.recent.row': 'By fonds gevoeg',
  'ef.rule':
      "'n Algemene vuistre\u00EBl is drie tot ses maande se noodsaaklike koste. "
      "Jou situasie kan verskil. Dit word op hierdie foon gestoor.",
  'ef.est.done': 'Hou dit vir egte noodgevalle.',
  'ef.est.none':
      "Voeg by wat jy elke maand kan spaar om 'n skatting te sien.",
  'ef.est.around': '(omtrent {date})',
  'ef.est.text':
      'Skatting: teen {amount} per maand, ongeveer {months}{when}. Die '
      'werklike lewe kan dit verander.',
  'chart.title': 'Daaglikse uitgawes',
  'chart.lastDays': 'Laaste {n} dae',
  'chart.empty':
      'Geen uitgawes die afgelope {n} dae aangeteken nie. Jou daaglikse '
      'balke verskyn hier sodra jy uitgawes aanteken.',
  'chart.semantics':
      'Staafgrafiek van daaglikse uitgawes vir die afgelope {n} dae. '
      'Vandag: {amount}.',
  'chart.wd.1': 'M',
  'chart.wd.2': 'D',
  'chart.wd.3': 'W',
  'chart.wd.4': 'D',
  'chart.wd.5': 'V',
  'chart.wd.6': 'S',
  'chart.wd.7': 'S',
  'home.greeting.morning': 'Goeie m\u00F4re',
  'home.greeting.afternoon': 'Goeie middag',
  'home.greeting.evening': 'Goeie naand',
  'home.payday.today': 'Betaaldag is vandag',
  'home.payday.tomorrow': 'Betaaldag is m\u00F4re',
  'home.payday.days': '{n} dae tot betaaldag',
  'home.hero.label': 'Oor om hierdie maand te spandeer',
  'home.hero.noBudget':
      'Stel jou maandelikse begroting om te sien wat jy oor het.',
  'home.hero.over': 'Oor begroting: {used}% van jou {budget} gebruik',
  'home.hero.used': '{used}% van jou {budget}-begroting gebruik',
  'home.view.overview': 'Oorsig',
  'home.view.spending': 'Nou se uitgawes',
  'home.score.semUnlocked': 'Moreki-telling: {score} uit 100',
  'home.score.semLocked':
      "Moreki-telling gesluit. Teken 'n bietjie meer aan om dit oop te sluit.",
  'home.score.of': 'uit 100',
  'home.score.locked': 'Gesluit',
  'home.score.unlockHint':
      "Teken 'n bietjie meer aan om jou telling oop te sluit. Stel 'n "
      "begroting en teken 3 uitgawes oor 2 verskillende dae aan.",
  'home.score.explanation':
      "Jou telling wys hoe jou uitgawes teen jou begroting pas en hoe "
      "konsekwent jy dit aanteken. Dit is nie 'n kredietelling nie.",
  'home.stat.score': 'Moreki-telling',
  'home.stat.budgetUsed': 'Begroting gebruik',
  'home.stat.biggest': 'Grootste uitgawe',
  'home.notSet': 'Nie gestel nie',
  'home.nothingYet': 'Nog niks',
  'home.bento.spent': 'Bestee hierdie maand',
  'home.bento.budget': 'Maandelikse begroting',
  'home.bento.logged': 'Uitgawes aangeteken',
  'home.spending.title': 'Waarheen dit hierdie maand gegaan het',
  'home.spending.empty':
      'Nog niks hierdie maand bestee nie. Sodra jy uitgawes aanteken, '
      'verskyn jou grootste kategorie\u00EB hier.',
  'home.spending.pct': '{n}% van uitgawes',
  'home.recent.title': 'Onlangse aktiwiteit',
  'home.recent.empty': 'Nog geen uitgawes nie. Jou nuutste verskyn hier.',
  'home.next.setBudget.title': 'Stel jou begroting',
  'home.next.setBudget.body':
      'S\u00EA vir Moreki wat jy hierdie maand kan spandeer.',
  'home.next.setBudget.button': 'Stel begroting',
  'home.next.over.title': 'Jy is {amount} oor jou begroting',
  'home.next.over.body':
      'Dit gebeur. Kyk waarheen dit gegaan het en beplan die res van die '
      'maand.',
  'home.next.over.button': 'Sien uitgawes',
  'home.next.high.title': 'Jy het {n}% van jou begroting gebruik',
  'home.next.high.body':
      'Gaan stadig met nie-noodsaaklike goed vir die res van die maand.',
  'home.next.high.button': 'Sien uitgawes',
  'home.next.log.title': "Teken 'n uitgawe aan",
  'home.next.log.body':
      "Nog 'n paar inskrywings en jou Moreki-telling word oopgesluit.",
  'home.next.log.button': 'Voeg uitgawe by',
  'home.next.ok.title': 'Jy is op koers',
  'home.next.ok.body': 'Hou aan aanteken sodat jou telling akkuraat bly.',
  'home.next.ok.button': 'Voeg uitgawe by',
  'plan.title': 'Plan',
  'plan.subtitle': 'Al jou geldinstrumente op een plek.',
  'plan.open': 'Maak oop',
  'plan.comingSoon': 'Binnekort',
  'plan.coach.title': 'Ask Moreki',
  'plan.coach.blurb':
      'Gestoorde antwoorde op algemene geldvrae. Nie lewendige KI nie.',
  'plan.fund.title': 'Noodfondsbouer',
  'plan.fund.blurb':
      "Stel 'n doel, volg jou spaargeld, sien jou vordering.",
  'plan.family.title': 'Gesinsbydrae-sakrekenaar',
  'plan.family.blurb':
      'Ondersteun jou gesin sonder om jou begroting te breek.',
  'plan.salary.title': 'Salarisdiagnose',
  'plan.salary.blurb': 'Sien waarheen jou salaris regtig gaan.',
  'plan.credit.title': 'Krediettelling-monitering',
  'plan.credit.blurb':
      'Verstaan jou krediet en hoe om dit te verbeter.',
  'plan.tax.title': 'Belastingopgawe eenvoudig',
  'plan.tax.blurb': 'Maak gereed vir belastingtyd sonder die stres.',
  'plan.hustle.title': 'Kantwerk-opspoorder',
  'plan.hustle.blurb': 'Hou ekstra inkomste en wat jy behou dop.',
  'plan.cover.title': 'Begrafnisdekking en mediese fonds-gids',
  'plan.cover.blurb': 'Maak sin van dekkingsopsies.',
  'plan.crisis.title': 'Krisismodus',
  'plan.crisis.blurb': "'n Kalm plan vir wanneer geld skraal raak.",
  'profile.title': 'Jou profiel',
  'profile.hi': 'Hallo, {name}',
  'profile.subtitle':
      'Geen rekening nodig nie. Alles word op hierdie foon gestoor.',
  'profile.nextPayday': 'Volgende betaaldag',
  'profile.today': 'Vandag',
  'profile.tomorrow': 'M\u00F4re',
  'profile.daysAway': '{n} dae',
  'profile.aboutYou': 'Oor jou',
  'profile.nameLabel': 'Voornaam of bynaam (opsioneel)',
  'profile.paydayLabel': 'Betaaldag, dag van die maand (opsioneel)',
  'profile.badDay': "Voer 'n dag van 1 tot 31 in",
  'profile.save': 'Stoor',
  'profile.saved': 'Op hierdie foon gestoor',
  'profile.language': 'Taal',
  'profile.languageNote':
      'Jou keuse is gestoor. Moreki werk in Engels, Frans en Afrikaans. '
      'Tshivenda en siSwati is beplan, maar nie in hierdie weergawe nie.',
  'profile.privacy': 'Privaatheid',
  'profile.privacyBody':
      "Jou syfers bly op hierdie foon. Moreki het nog nie 'n aanmelding nie, "
      "stuur nie jou data \u00EArens heen nie en skuif nooit geld vir jou nie.",
  'profile.about': 'Oor Moreki',
  'profile.aboutBody':
      "Moreki is 'n geldafrigter vir mense met hul eerste werk, gebou deur "
      "Cubic Code. Dit gee leiding, nie finansi\u00EBle advies nie. Ask "
      "Moreki gebruik gestoorde antwoorde, nie lewendige KI nie.",
  'profile.data': 'Jou data',
  'profile.dataBody':
      'Vee jou begroting, uitgawes, noodfonds, gesinsplan en profiel van '
      'hierdie foon af.',
  'profile.deleteButton': 'Vee al my data uit',
  'profile.deleteTitle': 'Vee al my data uit?',
  'profile.deleteBody':
      'Dit vee jou begroting, uitgawes, noodfonds, gesinsplan en profiel van '
      'hierdie foon uit. Dit kan nie ongedaan gemaak word nie.',
  'profile.cancel': 'Kanselleer',
  'profile.deleteEverything': 'Vee alles uit',
  'profile.deleted': 'Al jou data is van hierdie foon uitgevee',
  'fam.title': 'Gesinsbydrae',
  'fam.back': 'Terug',
  'fam.intro':
      'Om jou gesin te help is goed, en jy moet self ook reg wees. Werk '
      'uit watter bedrag jy elke maand kan aanhou stuur.',
  'fam.err.amount': "Voer 'n geldige bedrag in, soos 250 of 12.50",
  'fam.err.takeHome': 'Voer jou maandelikse netto salaris in',
  'fam.err.essentials': 'Voer jou maandelikse noodsaaklike uitgawes in',
  'fam.v.comfortable.title': 'Gemaklik',
  'fam.v.comfortable.body':
      'Jy kan {asked} stuur en steeds jou noodsaaklike uitgawes, jou '
      'spaargeld en jou persoonlike buffer dek. Jy sal elke maand {left} '
      'oor h\u00EA.',
  'fam.v.tight.title': 'Styf maar moontlik',
  'fam.v.tight.body':
      '{asked} is moontlik, maar dit gebruik {shortfall} van jou '
      'persoonlike buffer. Verbind jou net daartoe as jy dit elke maand '
      'kan volhou.',
  'fam.v.tooMuch.title': 'Te veel vir nou',
  'fam.v.tooMuch.bodySafe':
      "{asked} is {shortfall} meer as wat jou maand kan dra. 'n Kleiner "
      "bedrag wat bestendig bly, soos {safe}, is makliker om vol te hou. "
      "Dit is reg om met jou gesin te praat oor wat realisties is.",
  'fam.v.tooMuch.bodyNone':
      'Op die oomblik neem jou noodsaaklike uitgawes en spaargeld reeds '
      'die meeste van jou salaris, so daar is niks veilig om te stuur '
      'nie. Dit is reg om dit eerlik vir jou gesin te s\u00EA.',
  'fam.hero.label': 'Veilig om elke maand te stuur',
  'fam.hero.captionNone':
      'Voer jou syfers in om te sien wat veilig is om te stuur.',
  'fam.hero.captionSafe':
      "Omtrent {percent}% van jou netto salaris, na jou noodsaaklike "
      "uitgawes, spaargeld en 'n persoonlike buffer.",
  'fam.hero.captionZero':
      'Jou noodsaaklike uitgawes en spaargeld neem reeds die meeste van '
      'jou salaris.',
  'fam.row.takeHome': 'Netto salaris',
  'fam.row.essentials': 'Jou noodsaaklike uitgawes',
  'fam.row.savings': 'Jou spaargeld',
  'fam.row.buffer': 'Persoonlike buffer ({percent}%)',
  'fam.row.bufferSub': 'Vir jou gehou, sodat jy ook reg is',
  'fam.row.safe': 'Veilig om te stuur',
  'fam.panel.title': 'Jou syfers (per maand)',
  'fam.field.takeHome': 'Netto salaris (na belasting)',
  'fam.field.essentials':
      'Jou noodsaaklike uitgawes (huur, kos, vervoer, rekenings)',
  'fam.field.savings': 'Jou eie spaargeld (opsioneel)',
  'fam.field.requested': 'Waarvoor jou gesin vra (opsioneel)',
  'fam.calculate': 'Bereken',
  'fam.note':
      "Die persoonlike buffer van {percent}% is 'n vuistre\u00EBl, nie 'n "
      "streng re\u00EBl nie. Jou situasie kan verskil. Dit word op hierdie "
      "foon gestoor. Moreki skuif nooit geld vir jou nie.",
};
