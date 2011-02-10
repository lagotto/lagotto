CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doi` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `retrieved_at` datetime NOT NULL DEFAULT '1970-01-01 00:00:00',
  `pub_med` varchar(255) DEFAULT NULL,
  `pub_med_central` varchar(255) DEFAULT NULL,
  `published_on` date DEFAULT NULL,
  `title` text,
  `citations_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_on_doi` (`doi`)
) ENGINE=InnoDB AUTO_INCREMENT=959844140 DEFAULT CHARSET=utf8;

CREATE TABLE `citations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `retrieval_id` int(11) DEFAULT NULL,
  `uri` varchar(255) NOT NULL,
  `details` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_citations_on_retrieval_id_and_uri` (`retrieval_id`,`uri`),
  KEY `index_citations_on_retrieval_id` (`retrieval_id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190963 DEFAULT CHARSET=utf8;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=287030889 DEFAULT CHARSET=utf8;

CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `retrieval_id` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `citations_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_histories_on_retrieval_id_and_year_and_month` (`retrieval_id`,`year`,`month`)
) ENGINE=InnoDB AUTO_INCREMENT=980190963 DEFAULT CHARSET=utf8;

CREATE TABLE `retrievals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `source_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `retrieved_at` datetime NOT NULL DEFAULT '1970-01-01 00:00:00',
  `citations_count` int(11) DEFAULT '0',
  `other_citations_count` int(11) DEFAULT '0',
  `local_id` varchar(255) DEFAULT NULL,
  `running` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_retrievals_on_source_id_and_article_id` (`source_id`,`article_id`),
  KEY `retrievals_article_id` (`article_id`,`citations_count`,`other_citations_count`)
) ENGINE=InnoDB AUTO_INCREMENT=1040397644 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `staleness` int(11) DEFAULT '604800',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `name` varchar(255) DEFAULT NULL,
  `live_mode` tinyint(1) DEFAULT '0',
  `salt` varchar(255) DEFAULT NULL,
  `searchURL` varchar(255) DEFAULT NULL,
  `timeout` int(11) NOT NULL DEFAULT '30',
  `group_id` int(11) DEFAULT NULL,
  `disable_until` datetime DEFAULT NULL,
  `disable_delay` int(11) NOT NULL DEFAULT '10',
  `partner_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sources_on_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=365262435 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(40) DEFAULT NULL,
  `name` varchar(100) DEFAULT '',
  `email` varchar(100) DEFAULT NULL,
  `crypted_password` varchar(40) DEFAULT NULL,
  `salt` varchar(40) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `remember_token` varchar(40) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20081113233857');

INSERT INTO schema_migrations (version) VALUES ('20081114173758');

INSERT INTO schema_migrations (version) VALUES ('20081118183235');

INSERT INTO schema_migrations (version) VALUES ('20081118185107');

INSERT INTO schema_migrations (version) VALUES ('20081121154457');

INSERT INTO schema_migrations (version) VALUES ('20081122051039');

INSERT INTO schema_migrations (version) VALUES ('20081124061921');

INSERT INTO schema_migrations (version) VALUES ('20081124073438');

INSERT INTO schema_migrations (version) VALUES ('20081127002033');

INSERT INTO schema_migrations (version) VALUES ('20081203192956');

INSERT INTO schema_migrations (version) VALUES ('20081205171600');

INSERT INTO schema_migrations (version) VALUES ('20081205174929');

INSERT INTO schema_migrations (version) VALUES ('20081208232023');

INSERT INTO schema_migrations (version) VALUES ('20081212091354');

INSERT INTO schema_migrations (version) VALUES ('20081215010727');

INSERT INTO schema_migrations (version) VALUES ('20081229214209');

INSERT INTO schema_migrations (version) VALUES ('20090223195720');

INSERT INTO schema_migrations (version) VALUES ('20090303222502');

INSERT INTO schema_migrations (version) VALUES ('20090311212528');

INSERT INTO schema_migrations (version) VALUES ('20090313213702');

INSERT INTO schema_migrations (version) VALUES ('20090318213801');

INSERT INTO schema_migrations (version) VALUES ('20090319051504');

INSERT INTO schema_migrations (version) VALUES ('20090319062813');

INSERT INTO schema_migrations (version) VALUES ('20090713182750');

INSERT INTO schema_migrations (version) VALUES ('20091207204038');

INSERT INTO schema_migrations (version) VALUES ('20091207225429');

INSERT INTO schema_migrations (version) VALUES ('20100408211121');

INSERT INTO schema_migrations (version) VALUES ('20100629001517');

INSERT INTO schema_migrations (version) VALUES ('20100629212419');

INSERT INTO schema_migrations (version) VALUES ('20100811225645');

INSERT INTO schema_migrations (version) VALUES ('20101026191031');

INSERT INTO schema_migrations (version) VALUES ('20101217140525');

INSERT INTO schema_migrations (version) VALUES ('20101223214158');