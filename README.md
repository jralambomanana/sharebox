# A social network tool with your clients for your business

This application is a SharingFile System with surveys management facilities

[![Build Status](https://travis-ci.org/alexandrecuer/sharebox.svg?branch=master)](https://travis-ci.org/alexandrecuer/sharebox)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ed6f26a2613349e0a92b404d515a4b29)](https://www.codacy.com/app/alexandrecuer/sharebox?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=alexandrecuer/sharebox&amp;utm_campaign=Badge_Grade)

If you deliver files and documents to your clients and if you want to record your clients'satisfaction, this tool is for you
<img src=public/images/doc/colibri_front.png>

Online class documentation (not up to date) :
https://alexandrecuer.github.io/sharebox/

documentation is generated by yard (just launch ``yard doc`` in the root folder)

Check online prototype : https://desolate-earth-32333.herokuapp.com/

<b>
An automatic process is available for deployment on a linux Ubuntu server or virtual machine. It will install the required dependencies then the application in /var/www/colibri/sharebox.

When installing the server, reserve 8GB at least for the system and create a specific mounting point for /var/www

check : https://github.com/alexandrecuer/colibriScripts
</b>

Uses the following gems :
* 
* [devise](https://github.com/plataformatec/devise) for user authentification
* [passenger](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/heroku/standalone/oss/deploy_app_main.html) as the application server (in standalone mode)
* [aws-sdk](https://github.com/aws/aws-sdk-ruby) for storage on S3

frontoffice :
* [bootstrap](https://github.com/twbs/bootstrap-rubygem)
* [font-awesome](https://github.com/bokmann/font-awesome-rails) icons and cosmectic details
* [jquery rails](https://github.com/rails/jquery-rails)

## File storage

The application can use [paperclip](https://github.com/thoughtbot/paperclip) or rails [ActiveStorage](http://guides.rubyonrails.org/active_storage_overview.html) for file storage/documents processing (work in progress - see active_storage branch not yet merged into master)

As paperclip is deprecated, active storage is recommanded for new installations

For existant paperclip installations, a [migration guide](https://github.com/alexandrecuer/sharebox/issues/8) is available

An environment variable permits to define the storage engine
<table>
    <tr>
        <td>PAPERCLIP</td>
        <td>
            0 -> active storage<br>
            1 -> paperclip
        </td>
    </tr>
 </table>

Document storage is configured for : 
- Amazon S3 in production mode 
- local file system in development mode. In that case, the aws-sdk gem is not used.

Switching between S3 mode and local storage mode can be done by modifying : 
- /config/environments/development.rb 
- /config/environments/production.rb

corresponding model and controller can be found there :
- [app/models/asset.rb](app/models/asset.rb)
- [app/controllers/assets_controller.rb](app/controllers/assets_controller.rb) - see the get_file private method

to open a file, follow the route /forge/get/:id

### if using paperclip :

you have to modify the value of config.local_storage in the corresponding config/environments/*.rb file(s)

- config.local_storage = 1 : local storage will be activated
- config.local_storage = 0 : all files will go in the S3 bucket

paperclip files will be stored in the 'forge' directory : (rails_root or S3 bucket)/forge/attachments/:id/:filename

### if using active_storage :
<table>
<tr><td>config.active_storage.service = :local or :local_production</td><td> local storage will be activated</td></tr>
<tr><td>config.active_storage.service = :amazon</td><td> local storage will go in the S3 bucket</td></tr>
</table>

<table>
  <tr>
      <td></td>
      <td valign=top>S3 storage</td>
      <td valign=top>local storage</td>
  </tr>
  <tr>
      <td></td>
      <td colspan=2>has_one_attached :uploaded_file</td>
  </tr>
  <tr>
      <td></td>
      <td colspan=2>redirect_to asset.uploaded_file.service_url</td>
  </tr>
 </table>

##  S3 storage environmental variables

<table>
    <tr>
        <td>S3_BUCKET_NAME</td>
        <td><a href=https://devcenter.heroku.com/articles/s3#s3-setup>Heroku specific doc</a></td>
    </tr>
    <tr>
        <td>AWS_REGION</td>
        <td rowspan=2>
            <a href=https://docs.aws.amazon.com/fr_fr/general/latest/gr/rande.html#s3_region>AWS regional parameters</a><br> 
            exemple : <br>
            AWS_REGION=eu-west-3<br>
            AWS_HOST_NAME=s3.eu-west-3.amazonaws.com
        </td> 
    </tr>
    <tr>
        <td>AWS_HOST_NAME</td>
    </tr>
    <tr>
        <td>AWS_URL</td>
        <td>S3_BUCKET_NAME.AWS_HOST_NAME</td>
    </tr>
    <tr>
        <td>AWS_ACCESS_KEY_ID</td>
        <td rowspan=2>
            <a href=https://console.aws.amazon.com/iam/home#/users>IAM - Identity and Access Management</a>
        </td>
    </tr>
    <tr>
        <td>AWS_SECRET_ACCESS_KEY</td>
    </tr>
</table>

##  Mail delivery Environmental variables

<table>
    <tr>
        <td>GMAIL_USERNAME</td>
        <td rowspan=2>
          SendGrid is the preferred option<br>
          <a href=https://sendgrid.com/>sendgrid</a><br><br>
          <a href=https://mail.google.com/>gmail</a><br>
          Please note gmail is not a reliable solution as a backoffice mailer<br>
          if, however, you were considering using gmail for mail delivery, you may need to configure your google account in order to allow external applications to use it<br>
          <a href=https://www.google.com/settings/security/lesssecureapps>lesssecureapps</a><br>
          <a href=https://accounts.google.com/DisplayUnlockCaptcha>unlockcaptach</a><br>
        </td>
    </tr>
    <tr>
        <td>GMAIL_PASSWORD</td>
    </tr>
    <tr>
        <td>SMTP_ADDRESS</td>
        <td rowspan=2>example if using sendgrid :<br>SMTP_ADDRESS="smtp.sengrid.net"<br>SMTP_PORT=587</td>
    </tr>
    <tr>
      <td>SMTP_PORT</td>
    </tr>
    <tr>
      <td>DOMAIN</td>
      <td>In development mode : localhost<br>For a production server :ip address or domain name of the server</td>
    </tr>
</table>

# User management

5 different user profiles are available :

profile 0 : external user
--
customer who is not registered in the tool and who has received a token by email to answer a satisfaction survey not related to a deliverable

profile 1 : standard public user
--
customer who wants to access a deliverable and to complete an associated satisfaction survey, if any

profile 2 : team member
--
public user with address type "first_name.name@team_domain"

team member who wants to send customer satisfaction surveys without making deliverables available on the cloud

initialize TEAM config var with your domain name to make this work - otherwise there will be no difference between profile 1 and profile 2

profile 3 : private user
--
full team member who dematerializes his productions - private users can swarm one or more of their **root** directories in other private users'folders - this constitutes a primitive kind of collaborative work

profile 4 : admin
--
all powers - access to all directories and assets, surveys management, ability to modify directories (moving and changing ownership)

# Deployment to Heroku through GitHub integration
This application has been designed for an automatic deployment from github to the heroku cloud
You will need a S3 bucket as Heroku has an ephemeral file system
Here are the main steps :
- Fork and customize the repository to your needs
- Create a new Heroku app and link it to the GitHub repository previously forked
- Fill all the eleven needed config variables (AWS_ACCESS_KEY_ID, AWS_HOST_NAME, AWS_REGION, AWS_SECRET_ACCESS_KEY, AWS_URL, DOMAIN, GMAIL_PASSWORD, GMAIL_USERNAME, S3_BUCKET_NAME, SMTP_ADDRESS, SMTP_PORT plus an extra one: TEAM)
- Proceed to a manual deploy

To customize the application to your needs, check the following files 
- config/config.yml (site_name and admin_mel)
- config/initializers/devise.rb (config.mailer_sender)

admin_mel will receive activity notifications : new shares, pending users. Pending users are unregistered users benefiting from at least one shared access to a folder

config.mailer_sender will be the sending email as far as authentification issues are considered (eg password changes)

You can find the two site’s logos in the /app/assets/images directory

Please note that the first user to register in the system will be given admin rights !!

for more details : [deploy on heroku in images](/public/images/doc/deploy_on_heroku.pdf)


# Installation on Heroku (for production) from a development server
If you don't want to use the github integration method, an alternative option is possible

Install [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

Or https://cli-assets.heroku.com/branches/stable/heroku-windows-amd64.exe

Open your local app directory in a git bash, and login to Heroku :
```
$ cd /c/Sites/sharebox
$ heroku login
Enter your Heroku credentials:
Email: alexandre.cuer@cerema.fr
Password: *************
Logged in as alexandre.cuer@cerema.fr
```
Once succesfully logged, create a new heroku app :
```
$ heroku create
Creating app... done, desolate-earth-32333
https://desolate-earth-32333.herokuapp.com/ | https://git.heroku.com/desolate-earth-32333.git
```
Heroku will define a random name for your production server, here : desolate-earth-32333.

Push the files with git.
```
$ git init
$ git add .
$ git commit -a -m "Switch to production"
$ git push heroku master
```
Fix environmental variables (we assume you are using gmail)
```
$ heroku config:set S3_BUCKET_NAME="your_bucket"
$ heroku config:set AWS_REGION="your_region"
$ heroku config:set AWS_HOST_NAME="your_host_name"
$ heroku config:set AWS_URL="your_url"
$ heroku config:set AWS_ACCESS_KEY_ID="your_access_key"
$ heroku config:set AWS_SECRET_ACCESS_KEY="your_secret_access_key"
$ heroku config:set GMAIL_USERNAME="your_gmail_address"
$ heroku config:set GMAIL_PASSWORD="your_gmail_password"
$ heroku config:set SMTP_ADDRESS="smtp.gmail.com"
$ heroku config:set SMTP_PORT=587
$ heroku config:set DOMAIN="desolate-earth-32333.herokuapp.com"
```
If for some reason, one variable is not correctly fixed, you can correct it from the heroku dashboard.

Go to https://dashboard.heroku.com/apps > Settings > Reveal Config Vars

Create the database and the tables
```
$ heroku run rake db:schema:load
```

# Working behind a proxy server

If you work behind a proxy, please set http_proxy and https_proxy variables
```
$ export https_proxy="http://user_name:password@proxy_url:proxy_port"
$ export http_proxy="http://user_name:password@proxy_url:proxy_port"
```

# Installation on a microsoft windows development machine

Follow the [specific guide](public/images/doc/install_on_microsoft_window_dev_machine.md)
