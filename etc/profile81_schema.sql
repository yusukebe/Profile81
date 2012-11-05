CREATE TABLE user (
       `id` INT UNSIGNED AUTO_INCREMENT,
       `twitter_id` BIGINT UNSIGNED NOT NULL,
       `screen_name` VARCHAR(255) NOT NULL,
       `image_url` TEXT,
       `created_on` DATETIME NOT NULL,
       PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET utf8;

CREATE TABLE profile (
       `user_id` INT UNSIGNED NOT NULL,
       `body` TEXT,
       `facebook_name` VARCHAR(255),
       `created_on` DATETIME NOT NULL,
       `updated_on` DATETIME NOT NULL,
       PRIMARY KEY (`user_id`)
) ENGINE = InnoDB DEFAULT CHARSET utf8;

CREATE TABLE tag (
       `tag_name` VARCHAR(255) NOT NULL,
       `label` VARCHAR(255) NOT NULL,
       `user_count` INT UNSIGNED DEFAULT 0,
       `created_on` DATETIME NOT NULL,
       PRIMARY KEY (`tag_name`)
) ENGINE = InnoDB DEFAULT CHARSET utf8;

CREATE TABLE profile_tag (
       `id` INT UNSIGNED AUTO_INCREMENT,
       `tag_name` VARCHAR(255) NOT NULL,
       `tag_label` VARCHAR(255) NOT NULL,
       `user_id` VARCHAR(255) NOT NULL,
       `created_on` DATETIME NOT NULL,
       PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET utf8;
