USE vk;


CREATE TABLE `articles` (
`article_id` BIGINT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
`writer` BIGINT unsigned NOT NULL,
`articles_text` BLOB NOT NULL,
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
INDEX (`writer`),
FOREIGN KEY (`writer`) REFERENCES `users` (`id`)
);

CREATE TABLE `article_likes` (
`like_id` BIGINT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
`the_article` BIGINT unsigned NOT NULL,
`liker` BIGINT unsigned NOT NULL,
INDEX (`liker`),
FOREIGN KEY (`the_article`) REFERENCES `articles` (`article_id`),
FOREIGN KEY (`liker`) REFERENCES `users` (`id`)
);

CREATE TABLE `media_likes` (
`like_id` BIGINT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
`the_media` BIGINT unsigned NOT NULL,
`liker` BIGINT unsigned NOT NULL,
INDEX (`liker`),
INDEX (`the_media`),
FOREIGN KEY (`the_media`) REFERENCES `media`(`id`),
FOREIGN KEY (`liker`) REFERENCES `users` (`id`)
);

CREATE TABLE `black_list` (
`lists_id` BIGINT unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
`list_owner` BIGINT unsigned NOT NULL,
`banned_person` BIGINT unsigned NOT NULL,
INDEX (`list_owner`),
FOREIGN KEY (`list_owner`) REFERENCES `users` (`id`),
FOREIGN KEY (`banned_person`) REFERENCES `users` (`id`)
);

