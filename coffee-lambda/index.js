let https = require('https');
let util = require('util');

// Required Environment Variables:
//   channel_name: Into what channel the message should be posted
//   webhook_path: For slack, snip the following part from the URL - "https://hooks.slack.com/services/<webhook_path>"

exports.handler = function(event, context) {
  let webhook_path = process.env.hasOwnProperty("webhook_path") ? process.env.webhook_path : "THIS_WILL_FAIL_MAKE_SURE_TO_SET_ENV_VARS";
  let bot_username = process.env.hasOwnProperty("bot_username") ? process.env.bot_username : "CoffeeBot";
  let bot_emoji    = process.env.hasOwnProperty("bot_emoji")    ? process.env.bot_emoji    : ":coffee:";
  let channel_name = process.env.hasOwnProperty("channel_name") ? process.env.channel_name : "#coffee";

  let message = `Coffee brewing!  Check back in 10 minutes for the freshest brew and to turn off the pot.`;
  // TODO: Check DynamoDB for last button push
  //
  // if dynamo says button pushed less than 5 minutes ago
  //   do nothing
  // else if dynamo says "brew_on"
  //   if button pushed less than 1 hour ago
  //     update: "brew_off"
  //   else
  //     update: timestamp, "brew_on"
  // else
  //   update: timestamp, "brew_on"
  //
  //
  console.log(`Notification will be sent to the ${channel_name} channel`);
  let options = {
    method: 'POST',
    hostname: 'hooks.slack.com',
    port: 443,
    path: `/services/${webhook_path}`
  };
  console.log("options", options)
  let req = https.request(options, (res) => {
    res.setEncoding('utf8');
    res.on('data', (d) => { context.done(); });
  });
  req.on('error', (e) => { context.fail(e); });
  req.write(util.format("%j", {
    channel: channel_name,
    username: bot_username,
    icon_emoji: bot_emoji,
    text: message
  }));
  req.end();
};
