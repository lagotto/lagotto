Public:
	Contains the templates for use for the ALM Application

Sources:
	Contains PLoS Sources for the ALM Application

To build a local instance of the PLoS Specifc ALM follow these commands:

mkdir alm
svn co https://alt-metrics.googlecode.com/svn/trunk alm

mkdir alm.plos
svn co http://ambraproject.org/svn/plos/alm/head alm.plos

rm -rf alm/app/models/sources
ln -s ../../../alm.plos/sources alm/app/models/sources

rm -rf alm/public
ln -s ../alm.plos/public alm/public 

** create symbolic links to your localized config files.  I assume here that the alm_config folder was created earlier as a manual process.

ln -s ../../alm_config/database.yml alm/config/database.yml
ln -s ../../alm_config/settings.yml alm/config/settings.yml

