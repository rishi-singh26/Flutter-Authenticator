String getImageName(String issuer) {
  if (issuer.toLowerCase().contains('discord')) {
    return 'images/discord.png';
  }
  if (issuer.toLowerCase().contains('google')) {
    return 'images/google.png';
  }
  if (issuer.toLowerCase().contains('github')) {
    return 'images/github.png';
  }
  if (issuer.toLowerCase().contains('twitter')) {
    return 'images/twitter.png';
  }
  if (issuer.toLowerCase().contains('npm')) {
    return 'images/npm.png';
  }
  if (issuer.toLowerCase().contains('mega')) {
    return 'images/mega.png';
  }
  if (issuer.toLowerCase().contains('heroku')) {
    return 'images/heroku.png';
  }
  if (issuer.toLowerCase().contains('mongodb')) {
    return 'images/mongodb.png';
  }
  if (issuer.toLowerCase().contains('algolia')) {
    return 'images/algolia.png';
  }
  if (issuer.toLowerCase().contains('instagram')) {
    return 'images/instagram.png';
  }
  if (issuer.toLowerCase().contains('samsung')) {
    return 'images/samsung.png';
  }
  if (issuer.toLowerCase().contains('figma')) {
    return 'images/figma.png';
  }
  if (issuer.toLowerCase().contains('slack')) {
    return 'images/slack.png';
  }
  return 'account';
}
