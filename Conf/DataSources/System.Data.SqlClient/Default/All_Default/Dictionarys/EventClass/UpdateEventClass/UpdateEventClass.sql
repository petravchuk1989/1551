update Event_Class
set name = @name
,[execution_term]=@execution_term
,[assignment_class_id]=@assignment_class_id
where Id = @Id
