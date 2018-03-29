-- :name save-message! :! :n
-- creates a new message
INSERT INTO guestbook
(name, mess, timestamp)
VALUES (:name, :mess, :timestamp)

-- :name get-messages :? :*
-- selects all available messages
SELECT * from guestbook
