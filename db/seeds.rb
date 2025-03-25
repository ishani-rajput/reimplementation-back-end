begin
  #Create an institution
  inst_id = Institution.create!(
    name: 'North Carolina State University',
  ).id
  
  roles = {
    admin: Role.find_or_create_by!(name: 'Super Administrator'),
    instructor: Role.find_or_create_by!(name: 'Instructor'),
    student: Role.find_or_create_by!(name: 'Student')
  }
  

  # Create an admin user
  User.create!(
    name: 'admin',
    email: 'admin2@example.com',
    password: 'password123',
    full_name: 'admin admin',
    institution_id: 1,
    role_id:  roles[:admin].id,
  )
  

  #Generate Random Users
  num_students = 48
  num_assignments = 8
  num_teams = 16
  num_courses = 2
  num_instructors = 2
  
  puts "creating instructors"
  instructor_user_ids = []
  num_instructors.times do
    instructor_user_ids << User.create(
      name: Faker::Internet.unique.username,
      email: Faker::Internet.unique.email,
      password: "password",
      full_name: Faker::Name.name,
      institution_id: 1,
      role_id:  roles[:instructor].id,
    ).id
  end

  puts "creating courses"
  course_ids = []
  num_courses.times do |i|
    course_ids << Course.create(
      instructor_id: instructor_user_ids[i],
      institution_id: inst_id,
      directory_path: Faker::File.dir(segment_count: 2),
      name: Faker::Company.industry,
      info: "A fake class",
      private: false
    ).id
  end

  puts "creating assignments"
  assignment_ids = []
  num_assignments.times do |i|
    assignment_ids << Assignment.create(
      name: Faker::Verb.base,
      instructor_id: instructor_user_ids[i%num_instructors],
      course_id: course_ids[i%num_courses],
      has_teams: true,
      private: false
    ).id
  end


  puts "creating teams"
  team_ids = []
  num_teams.times do |i|
    team_ids << Team.create(
      assignment_id: assignment_ids[i%num_assignments]
    ).id
  end

  puts "creating students"
  student_user_ids = []
  num_students.times do
    student_user_ids << User.create(
      name: Faker::Internet.unique.username,
      email: Faker::Internet.unique.email,
      password: "password",
      full_name: Faker::Name.name,
      institution_id: 1,
      role_id:  roles[:student].id,
    ).id
  end

  puts "assigning students to teams"
  teams_users_ids = []
  #num_students.times do |i|
  #  teams_users_ids << TeamsUser.create(
  #    team_id: team_ids[i%num_teams],
  #    user_id: student_user_ids[i]
  #  ).id
  #end

  num_students.times do |i|
    puts "Creating TeamsUser with team_id: #{team_ids[i % num_teams]}, user_id: #{student_user_ids[i]}"
    teams_user = TeamsUser.create(
      team_id: team_ids[i % num_teams],
      user_id: student_user_ids[i]
    )
    if teams_user.persisted?
      teams_users_ids << teams_user.id
      puts "Created TeamsUser with ID: #{teams_user.id}"
    else
      puts "Failed to create TeamsUser: #{teams_user.errors.full_messages.join(', ')}"
    end
  end

  puts "assigning participant to students, teams, courses, and assignments"
  participant_ids = []
  num_students.times do |i|
    participant_ids << Participant.create(
      user_id: student_user_ids[i],
      assignment_id: assignment_ids[i%num_assignments],
      team_id: team_ids[i%num_teams],
    ).id
  end








rescue ActiveRecord::RecordInvalid => e
  puts "Seeding failed or the db is already seeded: #{e.message}"
end
