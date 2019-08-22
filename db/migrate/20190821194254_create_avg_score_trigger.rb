class CreateAvgScoreTrigger < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE FUNCTION update_avg_score_function() RETURNS trigger AS $update_avg_score_function$
        BEGIN
          IF    TG_OP = 'INSERT' THEN
            UPDATE posts
            SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
            WHERE id = NEW.post_id;

            RETURN NEW;
          ELSIF TG_OP = 'UPDATE' THEN
            IF NEW.post_id <> OLD.post_id OR NEW.value <> OLD.value THEN
              UPDATE posts
              SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
              WHERE id = NEW.post_id OR id = OLD.post_id;
            END IF;

            RETURN NEW;
          ELSIF TG_OP = 'DELETE' THEN
            UPDATE posts
            SET avg_score = (SELECT AVG(value * 100) FROM scores WHERE scores.post_id = posts.id)
            WHERE id = OLD.post_id;

            RETURN OLD;
          END IF;
        END
      $update_avg_score_function$ LANGUAGE plpgsql;

      CREATE TRIGGER update_avg_score_trigger
        AFTER INSERT OR UPDATE OR DELETE
        ON scores
        FOR ROW
        EXECUTE PROCEDURE update_avg_score_function()
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER update_avg_score_trigger ON scores CASCADE;

      DROP FUNCTION update_avg_score_function() CASCADE;
    SQL
  end
end
