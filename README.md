# Digital Grinnell (digital.grinnell.edu) Vagrant / Puppet Configuration

This repo contains the Vagrantfile and Puppet manifests + modules necessary
to build two servers that, together, will drive the future incarnation of
http://digital.grinnell.edu.

## Sanitization... ##
Please note that these manifests and associated files have been sanitized for
distribution by removing all Grinnell-specific usernames, passwords and similar
references, wherever possible.  Sanitized elements now appear as '!!!!xx!!!!',
'!!!!yy!!!!', etc., where 'xx' and 'yy' are included two-digit numbers used to
maintain consistency between various references to the same parameter.  For example,
the string '!!!!01!!!!' in the manifests (most notably in digital7.pp) represents
what was originally 'digital7', the host name of the front-end server.

A synopsis of all santization substitutions follows:


- 01 Front-end server hostname. Previously 'digital7'.
- 02 Back-end server hostname. Previously 'repository7'.
- 03 Production domain name. Previously 'grinnell.edu'.
- 04 Development domain name.  Previously 'grinnell.dev'.
- 05 Master password.
- 06 Drupal database name.  Previously 'digitalGrinnell'.
- 07 Fedora master password.
- 08 Fedora's MySQL database name.  Previously 'fedora3'.

Also note that there still may be many occurances of 'Grinnell', 'grinnell', 'digital' and other terms which have not been removed from the manifests and supporting files. It would be wise to find them and evaluate each to make any changes you like.

**IMPORTANT!!!!**  If you intend to 'restore' these files to a useable state be sure
you make whole-word substitutions through ALL of the files involved (perhaps with
the exception of this README.md file) and **do so IN REVERSE!**  That is, apply the
substitution for '!!!!08!!!!' first, then '!!!!07!!!!', and so on.

## The Servers ##

**digital7.grinnell.edu** - an Islandora v7.x VM featuring a simple LAMP stack plus
configured installs of:

<ul>
<li>Apache2</li>
<li>Drush</li>
<li>Drupal 7</li>
<li>Dynmotd</li>
<li>Git</li>
<li>Java</li>
<li>Webmin</li>
<li>XDebug</li>
</ul>

Also included are a host of Drupal 7 modules as prescribed in
https://github.com/ryersonlibrary/islandora/blob/master/attributes/default.rb and
other sources.

**repository7.grinnell.edu** - a Fedora Commons repository server VM featuring
configured installs of:

<ul>
<li>Fedora Commons 3.7.1</li>
<li>Java</li>
<li>Tomcat 7</li>
<li>Adore-Djatoka</li>
<li>Solr</li>
<li>Webmin</li>
<li>XDebug</li>
</ul>

## Notes
The scripts here are intended to be largely self-documenting.  See *Vagrantfile* and
*manifests/digital7.pp* and *mainfests/repository7.pp* to learn more.

See also http://puppetlabs.com/blog/lamp-stacks-made-easy-vagrant-puppet for
initial setup information.


Some great resources for Puppet...

-   http://www.puppetcookbook.com/
-   Drupal and Drush components (tried but abandoned) can be found at...
  http://bitfieldconsulting.com/puppet-drupal
- This work largely based on...
  https://github.com/drupalboxes/drupal-puppet and less so on...
  http://www.newmediacampaigns.com/blog/drupal-puppet-module
- Lots of boxes at...
  http://www.vagrantbox.es/

## Contributions (The @TODO List) ##
Feel free to fork this distribution as you like under the license terms indicated below.  If you would like to contribute to further development of these manifests we welcome your input.  In particular, it would be wonderful to...

1. Introduce a parameters manifest, a Hiera construct, or something similar to house all the configuration variables (all of the !!!!01!!!! key=>value pairs) and more.
2. The modules here are not nearly as 'modular' as they could be.  Make them so!
3. Plenty of other opportunities... just look for @TODO's in the code!

## License ##
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt)