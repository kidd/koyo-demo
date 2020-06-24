#lang north

-- @revision: 2869af35fe9a661a8f1f72a11729926a
-- @parent: efed79200bf19e497ce82c46ae7c7999
-- @description: Alters some table.
-- @up {
CREATE TABLE quotes(
       id uuid PRIMARY KEY,
       quote text NOT NULL UNIQUE
       );
-- }

-- @down {
DROP TABLE quotes;
-- }
