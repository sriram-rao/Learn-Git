require 'securerandom'
class TeamController < ApplicationController

    def new
        @course = Course.find_by_id(params[:id])
        x = current_user.teams.where(course_id: 2)
        if !@course.nil? && @course.mcount > 1 && x.empty?
            # @Team = Team.new
        else
            x = x.first
            puts "*"*100
            puts x.inspect
            if x.repos.empty?
                redirect_to root_path
            else
                redirect_to "/course/2"
            end
        end
    end

    def create
        #Expand to allow more than 1 user being invited
        user = User.where(email: params[:email])
        course = Course.find_by_id(params[:id])
        if !user.first.nil? && !course.nil? && (course.mcount > 1)
            user = user.first
            #Add a notification to the user
            makeNotification([user.id],"You have been invited by #{current_user.name} to join the team #{params[:tname]} for #{course.name} course!","Tinvite","/acceptInvite?course_id=#{course.id}")
            #create a new Team
            team = Team.new
            team.name = params[:tname]
            team.status = 0.00
            team.course_id = course.id
            team.acceptedInvites = 1
            team.save
            current_user.teams << team
            current_user.save
            user.teams << team
            user.save
            flash[:notice] = "#{user.name} has been invited to join the team. The course will begin when he accepts!"
        else
            flash[:notice] = "The user you want to add doesn't exist. Please ask him to join the site first!"
        end
        redirect_to(controller: "home",action: "index")
    end

    def acceptInvite
        course = Course.find(params[:id])
        if course
            team = current_user.teams.find_by_course_id(course.id)
            if team
                team.acceptedInvites+=1
                puts "Accepted !!!team"
                if team.acceptedInvites == course.mcount
                    tmp=1
                    team.users.each do |q|
                        createRepo(q.id,course.id,tmp)
                        tmp+=1
                    end
                end
                puts team.inspect
                team.save
            end
        end
        redirect_to "/course/2"
    end



    private

    def createRepo(user_id,course_id,tmp)

        user = User.find(user_id)
        course = Course.find(course_id)
        team = user.teams.select{|t| t.course_id = course_id}.first

        if user && course && team
            z = SecureRandom.hex(16)
            repo = Repo.new
                repo.name = z #TODO: Allow user to name his repo?
                repo.user_id = user.id
                repo.team_id = team.id
                repo.course_id = course.id
                repo.status = 1
                `mkdir #{Dir.pwd}/../repositories/#{z}`
                `cp #{Dir.pwd}/../courses/#{course_id}/ #{Dir.pwd}/../repositories/#{z}`
                repo.path ="../repositories/#{z}"
                if (tmp == 1) #TODO: Order to be populated dynamically
                    repo.order = [1,2,3,4,8,10,11,12]
                else
                    repo.order = [1,2,3,5,6,7,8,9]
                end
                repo.save
              end
    end


end
