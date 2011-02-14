Public:
	Contains the templates for use for the ALM Application

Sources:
	Contains PLoS Sources for the ALM Application

To build a local instance of the PLoS Specifc ALM follow these commands:

mkdir alm
cd alm

svn co https://alt-metrics.googlecode.com/svn/trunk .

rm -rf app/models/sources
mkdir app/models/sources
svn co http://ambraproject.org/svn/plos/alm/head/sources app/models/sources

rm -rf public
mkdir public
svn co http://ambraproject.org/svn/plos/alm/head/public public

** create symbolic links to your localized config files.  I assume here that the alm_config folder was created earlier as a manual process.

cd config
ln -s ../../alm_config/database.yml database.yml
ln -s ../../alm_config/settings.yml settings.yml

