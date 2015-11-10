# Installation

## Build toolkit and cli_wallet

Start with BitShares 2.0 toolkit installation https://github.com/bitshares/bitshares-2. Follow instructions from README file.

I recommend to launch 4 witness nodes for redundancy, find shell script example that launches the nodes in config/deploy/wns.sh.

This faucet software requires persistent connection to one instance of cli_wallet - it's used to register accounts, start it with the following command:
```
screen -S cli
./programs/cli_wallet/cli_wallet -r 127.0.0.1:8099 -s ws://127.0.0.1:8090
```

_please note - screen command is used to help it to run in the background_

Don't forget to fund your faucet account and upgrade it to lifetime membership so it could register users' accounts.

After you start cli_wallet, create password and import faucet account key, the faucet account name needs to be specified in config/faucet.yml as registrar_account.


## Build web wallet

Find source code and building instructions here https://github.com/bitshares/bitshares-2-ui.
Before compiling it, edit SettingsStore.jsx, and put your values for connection and faucet_address.
If you able to build it successfully, web/dist should contain several html, js and css files.


Now it's time to install Ruby and Ruby On Rails:


## OS X Ruby and RoR installation

```
 $ brew install rbenv
 $ rbenv install 2.2.3
 $ rbenv global 2.2.3
 $ cd faucet
 $ bundle
 $ rake db:create; rake db:migrate; rake db:seed
 $ rails s
```

## Linux Ruby and RoR installation

See config/deploy/provision.sh.

Please note that provision.sh compiles and installs nginx web server, example configuration file can be in config/deploy/nginx.conf.


## Deployment

If you are using different machine for production and development I recommend to use mina for deployment.
Its configuration file is config/deploy.rb, you need to edit this file put your own parameters for :domain, :user, :repository and :branch.

Before deploying to production machine, copy web wallet dist files to public/wallet dir (or symlink bitshares-2-ui/web/dist to public/wallet).

These are commands I use to deploy it with mina:
```
mina setup
mina deploy
mina wallet # this will deploy wallet application located in public/wallet
```
After the deployment you should see /www/current dir pointing to /www/releases/1 and several shared directories in /www/shared.


# Configuration

1. Generate a new secret string via `rake secret` command and replace production entry in config/secrets.yml
2. Edit faucet.yml, put values relevant to your setup
3. Try to start RoR via `rails s` command, if no errors arise, go to step #4
4. Configure and launch nginx (find config example in config/deploy/nginx.conf)
5. Test if http://yoursite.domain loads and you can see web wallet's create account page
6. Now try register account, watch dev console to make sure no errors arise.


# API

Create referral code:
```
curl -i -d "refcode[code]=code4&refcode[account]=someaccount&refcode[asset_symbol]=BTS&refcode[asset_amount]=100000" http://localhost:3000/api/v1/referral_codes
```

Claim referral code:
```
curl -i http://localhost:3000/api/v1/referral_codes/code41/claim?account=someaccount
```