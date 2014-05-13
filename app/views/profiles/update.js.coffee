$(".upload-form").html("<%= j render(partial: 'profiles/edit_avatar', locals: { profile: @profile, user: @user }) %>")
