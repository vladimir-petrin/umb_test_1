class CreateUpdateAvgScoreTrigger < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE FUNCTION update_avg_score_function() RETURNS trigger AS $update_avg_score_function$
        BEGIN
          IF    TG_OP = 'INSERT' THEN
            INSERT INTO avg_scores (post_id, avg_value)
            VALUES (NEW.post_id, COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = NEW.post_id), 0))
            ON CONFLICT (post_id)
            DO UPDATE SET avg_value = COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = NEW.post_id), 0);

            RETURN NEW;
          ELSIF TG_OP = 'UPDATE' THEN
            IF NEW.value <> OLD.value OR NEW.post_id <> OLD.post_id THEN
              INSERT INTO avg_scores (post_id, avg_value)
              VALUES (NEW.post_id, COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = NEW.post_id), 0))
              ON CONFLICT (post_id)
              DO UPDATE SET avg_value = COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = NEW.post_id), 0);

              IF NEW.post_id <> OLD.post_id THEN
                INSERT INTO avg_scores (post_id, avg_value)
                VALUES (OLD.post_id, COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = OLD.post_id), 0))
                ON CONFLICT (post_id)
                DO UPDATE SET avg_value = COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = OLD.post_id), 0);
              END IF;
            END IF;

            RETURN NEW;
          ELSIF TG_OP = 'DELETE' THEN
            INSERT INTO avg_scores (post_id, avg_value)
            VALUES (OLD.post_id, COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = OLD.post_id), 0))
            ON CONFLICT (post_id)
            DO UPDATE SET avg_value = COALESCE((SELECT AVG(value * 100) FROM scores WHERE scores.post_id = OLD.post_id), 0);

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
