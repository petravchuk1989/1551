select count(id) cnt
from PollsApplicants
where poll_id = @pollId