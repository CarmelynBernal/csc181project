---------------------------- PC_USER TABLE SCRIPT

-- @desc Use this function to add user data

CREATE OR REPLACE
	FUNCTION setUser(p_user_id TEXT,
						p_fuser_name full_name,
						p_college TEXT,
						p_department TEXT,
						p_email_add TEXT,
						p_address TEXT,
						p_phone_number TEXT,
						p_account_type TEXT,
						p_password TEXT)
	RETURNS TEXT AS

	$$

		DECLARE

			v_user_instance TEXT;

		BEGIN
			SELECT INTO v_user_instance email_add FROM pc_user
			WHERE email_add = p_email_add;

			IF v_user_instance ISNULL THEN

				INSERT INTO pc_user(user_id,
								fuser_name,
								college,
								department,
								email_add,
								address,
								phone_number,
								account_type,
								password)
				VALUES(p_user_id,
					p_fuser_name,
					p_college,
					p_department,
					p_email_add,
					p_address,
					p_phone_number,
					p_account_type,
					p_password);

				RETURN 'OK';
			ELSE RETURN  'NOT OK';
			END IF;

		END;
$$
LANGUAGE 'plpgsql';

-- @desc Function to edit user details

CREATE OR REPLACE
	FUNCTION editUserDetails(p_user_id TEXT,
							p_email_add TEXT,
							p_address TEXT,
							p_phone_number TEXT)
RETURNS TEXT AS

$$

	BEGIN

		UPDATE pc_user
		SET email_add = p_email_add,
			address = p_address,
			phone_number = p_phone_number
		WHERE user_id = p_user_id;

		RETURN 'OK';

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to change user password

CREATE OR REPLACE
	FUNCTION changePassword (p_new_password TEXT,
							p_user_id TEXT)
RETURNS TEXT AS
$$

	BEGIN

		UPDATE pc_user
		SET password = p_new_password
		WHERE user_id = p_user_id;

		RETURN 'OK';

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to retrieve password per user id

CREATE OR REPLACE
	FUNCTION getPassword (IN TEXT,
						OUT TEXT)
RETURNS TEXT AS
$$

	SELECT password FROM pc_user WHERE user_id = $1;

$$
LANGUAGE 'sql';

-- @desc Function to retrieve user details per user id

CREATE OR REPLACE
	FUNCTION extractUserDetailsPerId(IN TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT,
								OUT TEXT)
	RETURNS SETOF RECORD AS
$$

	SELECT user_id,
			(fuser_name).first_name,
			(fuser_name).last_name,
			college,
			department,
			email_add,
			address,
			phone_number,
			account_type
	FROM pc_user
	WHERE user_id = $1;

$$
LANGUAGE 'sql';

-- @desc Function to check account existence using id and password.

CREATE OR REPLACE FUNCTION
	checkAccountExistence(IN TEXT,
						IN TEXT,
						OUT TEXT,
						OUT TEXT)
RETURNS SETOF RECORD AS
$$

	SELECT user_id, account_type
	FROM pc_user
	WHERE user_id = $1 AND
		  password = $2;

$$
LANGUAGE 'sql';

-- @desc Function to check user existence using id.

CREATE OR REPLACE FUNCTION
	checkUserExistence(IN TEXT, OUT TEXT)
RETURNS TEXT AS
$$

	SELECT user_id
	FROM pc_user
	WHERE user_id = $1;

$$
LANGUAGE 'sql';

-- @desc Use this function to get user id's of specific account types.

CREATE OR REPLACE FUNCTION getList(IN TEXT,
			OUT TEXT)
RETURNS TEXT AS
$$

	SELECT user_id
	FROM pc_user
	WHERE account_type = $1;

$$
LANGUAGE 'sql';

-- @desc use this function to get user list with details for pagination

CREATE OR REPLACE FUNCTION getUsersLimitOffset(IN TEXT,
												IN INT,
												IN INT,
												OUT TEXT,
												out text,
												out text,
												out text,
												out text)
RETURNS SETOF RECORD AS
$$
	SELECT user_id,
			(fuser_name).first_name,
			(fuser_name).last_name,
			department,
			college
	FROM pc_user
	WHERE account_type = $1 LIMIT $2 OFFSET $3;
$$
LANGUAGE 'sql';

-- @desc function returns true if password matches user id, false, otherwise

CREATE OR REPLACE FUNCTION userAuthentication(p_user_id TEXT, p_password TEXT)
RETURNS BOOLEAN AS
$$
DECLARE
	v_user_id TEXT;
	v_password TEXT;
BEGIN
	SELECT into v_user_id,v_password user_id,password FROM pc_user where user_id = p_user_id;
	if v_password = p_password THEN
		RETURN TRUE;
	ELSE RETURN FALSE;
	end if;
END;
$$
LANGUAGE 'plpgsql';


------------------------------------------------- PC_SCHEDULE TABLE SCRIPT


-- @desc Function to create schedule ranges

CREATE OR REPLACE
	FUNCTION setSchedule(p_from_time TIME,
						p_to_time TIME)
RETURNS INT AS
$$

	DECLARE

		v_sched_from_time TIME;
		v_sched_to_time TIME;
		v_sched_id INT;

	BEGIN

			SELECT INTO v_sched_from_time, v_sched_to_time
						sched_from_time, sched_to_time
			FROM pc_schedule
			WHERE sched_from_time = p_from_time
			AND sched_to_time = p_to_time;

			IF v_sched_from_time ISNULL AND v_sched_to_time ISNULL THEN
				INSERT INTO pc_schedule(sched_from_time,
									sched_to_time)
				VALUES (p_from_time,
						p_to_time);

			END IF;

			SELECT
			INTO v_sched_id sched_id
			FROM pc_schedule
			WHERE sched_from_time = p_from_time
			AND sched_to_time = p_to_time;

			RETURN v_sched_id;

	END;

	$$
LANGUAGE 'plpgsql';

-- @desc Function to retrieve schedule information per schedule id

CREATE OR REPLACE
FUNCTION extractSchedInfoFromSchedID(IN INT,
									OUT INT,
									OUT TIME,
									OUT TIME)
RETURNS SETOF RECORD AS
$$

	SELECT sched_id,
			sched_from_time,
			sched_to_time
	FROM pc_schedule
	WHERE sched_id = $1;

$$
LANGUAGE 'sql';

-- @desc Function to check schedule existence per schedule id. Returns schedule id if found.

CREATE OR REPLACE
FUNCTION checkSchedExistencePerID(IN INT,
								OUT INT)
RETURNS SETOF INT AS
$$

	SELECT sched_id
	FROM pc_schedule
	WHERE sched_id = $1;

$$
LANGUAGE 'sql';

-- @desc Function to check schedule existence per schedule time range. Returns schedule id if found.

CREATE OR REPLACE
FUNCTION getSchedIDPerTimeRange(IN TIME,
								IN TIME,
								OUT INT)
RETURNS SETOF INT AS
$$

	SELECT sched_id
	FROM pc_schedule
	WHERE sched_from_time = $1
		AND sched_to_time = $2;

$$
LANGUAGE 'sql';





------------------------------------------------------------ PC_PROFESSOR_SCHEDULE TABLE SCRIPT

-- @desc Function to add schedule to professor. Returns generated professor-schedule id.

CREATE OR REPLACE
	FUNCTION addScheduleToProfessor(p_prof_id TEXT,
									p_sched_id INT,
									p_sched_day TEXT)
	RETURNS INT AS
$$

		DECLARE

			v_prof_sched_id INT;
			v_account_type TEXT;
			v_prof_id TEXT;
			v_sched_id INT;
			v_sched_day TEXT;

		BEGIN

			SELECT INTO v_account_type account_type FROM pc_user WHERE user_id = p_prof_id;

			IF v_account_type = 'Professor' THEN

				SELECT INTO v_prof_id, v_sched_id, v_sched_day
						prof_id, sched_id, sched_day
				FROM pc_professor_schedule
				WHERE ((prof_id = p_prof_id AND sched_id = p_sched_id) AND sched_day = p_sched_day);

				IF v_prof_id ISNULL AND v_sched_id ISNULL AND v_sched_day ISNULL THEN

					INSERT INTO pc_professor_schedule (prof_id,
														sched_id,
														sched_day)
					VALUES(p_prof_id,
						p_sched_id,
						p_sched_day);

				END IF;

				SELECT INTO v_prof_sched_id prof_sched_id
				FROM pc_professor_schedule
				WHERE prof_id = p_prof_id
					AND sched_id = p_sched_id
					AND sched_day = p_sched_day;

				RETURN v_prof_sched_id;

			ELSE RETURN -1;

			END IF;

		END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to get schedule id using professor id

CREATE OR REPLACE
FUNCTION getSchedIDsPerProfID(IN TEXT,
								OUT INT)
RETURNS SETOF INT AS
$$

	SELECT sched_id
	FROM pc_professor_schedule
	WHERE prof_id = $1;

$$
LANGUAGE 'sql';

-- @desc Function to edit schedule of professors.

CREATE OR REPLACE
	FUNCTION editProfessorSchedule (p_old_sched_id INT,
									p_new_sched_id INT,
									p_prof_id TEXT)
RETURNS TEXT AS
$$

	DECLARE

		v_prof_sched_id INT;

	BEGIN

		SELECT INTO v_prof_sched_id prof_sched_id
		FROM pc_professor_schedule
		WHERE prof_id = p_prof_id AND sched_id = p_old_sched_id;

		IF v_prof_sched_id ISNULL THEN

			RETURN 'NOT OK';

		ELSE

			UPDATE pc_professor_schedule
			SET sched_id = p_new_sched_id
			WHERE prof_sched_id = v_prof_sched_id;

			RETURN 'OK';

		END IF;

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to get professor schedule id given sched_to_time, sched_from_time and sched_day.

CREATE OR REPLACE
	FUNCTION getProfSchedID (IN TIME,
							IN TIME,
							IN TEXT,
							OUT INT)
RETURNS SETOF INT AS
$$

	SELECT prof_sched_id
	FROM pc_professor_schedule
	WHERE sched_id = (SELECT sched_id
						FROM pc_schedule
						WHERE sched_from_time = $1
							AND sched_to_time = $2)
		AND sched_day = $3;

$$
LANGUAGE 'sql';

-- @desc This function deletes entries from the professor schedule table

CREATE OR REPLACE FUNCTION deleteProfSched(p_prof_id TEXT,
											p_sched_id INT)
RETURNS TEXT AS
$$
	BEGIN

		DELETE FROM pc_professor_schedule
		WHERE prof_id = p_prof_id
			AND sched_id = p_sched_id;

		RETURN 'OK';

	END;
$$
LANGUAGE 'plpgsql';

-- @desc This function gets sched day from professor schedule table

CREATE OR REPLACE FUNCTION getSchedDay(IN TEXT,
										IN INT,
										OUT TEXT)
RETURNS TEXT AS
$$
	SELECT sched_day
	FROM pc_professor_schedule
	WHERE prof_id= $1
	AND sched_id=$2;
$$
LANGUAGE 'sql';

-----------------------------------APPOINTMENT TABLE SCRIPT

-- @desc Function to create new appointment. Returns generated appointment id.

CREATE OR REPLACE
	FUNCTION setAppointment(p_prof_id TEXT,
							p_stud_id TEXT,
							p_sched_id INT,
							p_appointment_date DATE,
							p_message TEXT)
RETURNS INT AS
$$

	DECLARE

		v_appointment_id INT;
		v_prof_id TEXT;
		v_stud_id TEXT;

	BEGIN

		SELECT INTO v_prof_id, v_stud_id prof_id, stud_id
		FROM pc_appointment
		WHERE prof_id = p_prof_id AND stud_id = p_stud_id;

		IF v_prof_id ISNULL AND v_stud_id ISNULL THEN

			INSERT INTO pc_appointment(state_viewed,
										status,
										prof_id,
										stud_id,
										sched_id,
										appointment_date,
										message)
			VALUES ('FALSE',
					'Pending',
					p_prof_id,
					p_stud_id,
					p_sched_id,
					p_appointment_date,
					p_message);

		END IF;

		SELECT INTO v_appointment_id appointment_id
		FROM pc_appointment
		WHERE prof_id = p_prof_id AND stud_id = p_stud_id;

		RETURN v_appointment_id;

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to change state_viewed from to TRUE indicating appointment has been viewed by user.

CREATE OR REPLACE FUNCTION
	changeState(p_appointment_id INT)
RETURNS TEXT AS
$$

	BEGIN

		UPDATE pc_appointment
		SET state_viewed = TRUE
		WHERE appointment_id = p_appointment_id;

		RETURN 'OK';

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to change status to TRUE indicating appointment is not pending anymore.

CREATE OR REPLACE
	FUNCTION changeStatus(p_appointment_id INT, p_status TEXT)
RETURNS INT AS
$$

	BEGIN

		UPDATE pc_appointment
		SET status = p_status
		WHERE appointment_id = p_appointment_id;

		RETURN p_appointment_id;

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to delete appointments.

CREATE OR REPLACE
	FUNCTION deleteAppt(p_appointment_id INT)
RETURNS TEXT AS
$$

	BEGIN

		DELETE FROM pc_appointment
		WHERE appointment_id = p_appointment_id;

		RETURN 'OK';

	END;

$$
LANGUAGE 'plpgsql';

-- @desc Function to retrieve set of appointment id's approved by professor.

CREATE OR REPLACE
	FUNCTION getApptIDsPerUserId(IN TEXT,IN TEXT, OUT INT)
RETURNS SETOF INT AS
$$

	SELECT appointment_id
	FROM pc_appointment
	WHERE (prof_id = $1 AND status = $2) OR (stud_id = $1 AND status = $2);

$$
 LANGUAGE 'sql';

 CREATE OR REPLACE FUNCTION getApptList(IN TEXT,
                        IN TEXT,
                        IN INT,
                        IN INT,
                        OUT INT,
												OUT TEXT,
												OUT TEXT,
												OUT TEXT,
												OUT INT,
												OUT DATE,
												OUT TEXT)
RETURNS SETOF RECORD AS
$$
	SELECT appointment_id,
	      status,
	      prof_id,
			  stud_id,
			  sched_id,
			  appointment_date,
			  message
	FROM pc_appointment
	WHERE (prof_id = $1 OR stud_id = $1)
	AND status = $2
	LIMIT $3 OFFSET $4;
$$
LANGUAGE 'sql';

-- @desc Use this function to get list of appointment ids between specified professor id and student id

CREATE OR REPLACE
	FUNCTION getApptIDPerStudProfId(IN prof_id TEXT,
									IN stud_id TEXT)
RETURNS SETOF INT AS
$$

	SELECT appointment_id
	FROM pc_appointment
	WHERE prof_id = $1 AND stud_id = $2;

$$
LANGUAGE 'sql';

 -- @desc Use this function to get appointment details using appointment id for professor profile

CREATE OR REPLACE
	FUNCTION getApptDetailsProfView(IN INT,
							OUT TEXT,
							OUT TEXT,
							OUT TEXT,
							OUT TEXT,
							OUT TIME,
							OUT TIME,
							OUT DATE,
							OUT TEXT,
              OUT TEXT)
RETURNS setof RECORD AS
$$

	SELECT pc_appointment.stud_id,
          (fuser_name).first_name,
          (fuser_name).last_name,
          pc_user_meta.meta_value,
          pc_schedule.sched_from_time,
          pc_schedule.sched_to_time,
          pc_appointment.appointment_date,
          pc_appointment.message,
          pc_appointment.status
  FROM pc_appointment, pc_user, pc_schedule, pc_user_meta
	WHERE pc_user.user_id = pc_appointment.stud_id
        AND pc_user_meta.meta_key = 'Course'
        AND pc_user_meta.user_id = pc_appointment.stud_id
        AND pc_schedule.sched_id = pc_appointment.sched_id
        AND appointment_id = $1;

$$
LANGUAGE 'sql';

-- @desc Use this function to get appointment details using appointment id for student profile

CREATE OR REPLACE
	FUNCTION getApptDetailsStudView(IN INT,
							OUT TEXT,
							OUT TEXT,
							OUT TEXT,
							OUT TIME,
							OUT TIME,
							OUT DATE,
							OUT TEXT,
              OUT TEXT)
RETURNS setof RECORD AS
$$

	SELECT pc_appointment.prof_id,
          (fuser_name).first_name,
          (fuser_name).last_name,
          pc_schedule.sched_from_time,
          pc_schedule.sched_to_time,
          pc_appointment.appointment_date,
          pc_appointment.message,
          pc_appointment.status
  FROM pc_appointment, pc_user, pc_schedule
	WHERE pc_user.user_id = pc_appointment.prof_id
        AND pc_schedule.sched_id = pc_appointment.sched_id
        AND appointment_id = $1;

$$
LANGUAGE 'sql';

-- @desc The following functions get list of appointments with details for student and professor profile view

CREATE OR REPLACE FUNCTION apptDisplayProf(IN TEXT,
                                        IN INT,
                                        IN INT,
										IN TEXT,
                                        OUT TEXT,
                                        OUT TEXT,
                                        OUT DATE,
                                        OUT TIME,
                                        OUT INT)
 RETURNS SETOF RECORD AS
  $$

SELECT (fuser_name).first_name,
        (fuser_name).last_name,
        pc_appointment.appointment_date,
        pc_schedule.sched_from_time,
        pc_appointment.appointment_id
FROM pc_user,
      pc_schedule,
      pc_appointment
WHERE pc_user.user_id = pc_appointment.stud_id
      AND pc_schedule.sched_id = pc_appointment.sched_id
      AND pc_appointment.prof_id = $1
      AND pc_appointment.status = $4

LIMIT $2 OFFSET $3;

$$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION apptDisplayStud(IN TEXT,
                                        IN INT,
                                        IN INT,
										IN TEXT,
                                        OUT TEXT,
                                        OUT TEXT,
                                        OUT DATE,
                                        OUT TIME,
                                        OUT INT)
 RETURNS SETOF RECORD AS
  $$

SELECT (fuser_name).first_name,
        (fuser_name).last_name,
        pc_appointment.appointment_date,
        pc_schedule.sched_from_time,
        pc_appointment.appointment_id
FROM pc_user,
      pc_schedule,
      pc_appointment
WHERE pc_user.user_id = pc_appointment.prof_id
      AND pc_schedule.sched_id = pc_appointment.sched_id
      AND pc_appointment.stud_id = $1
      AND pc_appointment.status = $4

LIMIT $2 OFFSET $3;

$$
LANGUAGE 'sql';
------------------------------- PC_USER_META TABLE SCRIPT

-- @desc Function to retrieve meta_value from table pc_user_meta using user_id and meta_key.

CREATE OR REPLACE
	FUNCTION getUserMeta(IN TEXT,
						IN TEXT,
						OUT TEXT)
RETURNS TEXT AS
$$

	SELECT meta_value
	FROM pc_user_meta
	WHERE user_id = $1 AND meta_key = $2;

$$
LANGUAGE 'sql';


------name search (firstname OR lastname)
------case-insensitive
------pattern matching
------with limit offset

CREATE OR REPLACE FUNCTION getUsersLimitOffsetNameSearch(IN TEXT, IN TEXT,
IN INT,
IN INT,
OUT TEXT,
out text,
out text,
out text,
out text)
RETURNS SETOF RECORD AS
$$
SELECT user_id,
(fuser_name).first_name,
(fuser_name).last_name,
department,
college
FROM pc_user
WHERE account_type = $1 AND LOWER((fuser_name).first_name) like LOWER($2 || '%') or LOWER((fuser_name).last_name) like LOWER($2 || '%') LIMIT $3 OFFSET $4;
$$
LANGUAGE 'sql';
------------------------------- PC_SESSION TABLE SCRIPTS

-- @desc Function to insert a session into the table

CREATE OR REPLACE FUNCTION saveSessionID(p_session_id TEXT,
                                        p_user_id TEXT)
RETURNS BOOLEAN AS
$$
DECLARE
  v_session_instance TEXT;
BEGIN
  SELECT INTO v_session_instance session_id
  FROM pc_session
  WHERE session_id = p_session_id;

  IF v_session_instance ISNULL THEN
    INSERT INTO pc_session (session_id, user_id)
    VALUES (p_session_id, p_user_id);
    RETURN TRUE;
  ELSE RETURN FALSE;
  END IF;
END;
$$
LANGUAGE 'plpgsql';

-- @desc Function to retrieve user id using session id

CREATE OR REPLACE FUNCTION getUser(IN TEXT, OUT TEXT)
RETURNS TEXT AS
$$
SELECT user_id
FROM pc_session
WHERE session_id = $1;
$$
LANGUAGE 'sql';

-- @desc Trigger function that automatically deletes old data (> 5 days)
CREATE OR REPLACE FUNCTION deleteOldSessions() RETURNS trigger
LANGUAGE plpgsql
AS
$$
DECLARE
  row_count INT;
BEGIN
  DELETE FROM pc_session
  WHERE timestamp < NOW() - INTERVAL '5 days';

  IF found THEN GET DIAGNOSTICS row_count = ROW_COUNT;
  RAISE NOTICE 'DELETED % row(s) FROM limiter', row_count;
  END IF;

  RETURN NEW;
END;
$$;

--@desc Function that deletes a session from the pc_session

CREATE OR REPLACE FUNCTION deleteSession(p_session_id TEXT)
RETURNS TEXT AS
$$
BEGIN
  DELETE FROM pc_session
  WHERE session_id = p_session_id;

  RETURN 'OK';

END;
$$
LANGUAGE 'plpgsql';

-- @desc setting the trigger to execute every insertion

CREATE TRIGGER del_sessions
AFTER INSERT ON pc_session
EXECUTE PROCEDURE deleteOldSessions();

