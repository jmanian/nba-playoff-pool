class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # After updating email/password, return to the profile page (matching the
  # profile form) instead of Devise's default, which is signed_in_root_path.
  # We override here rather than defining a `user_root` route because that
  # route would also change where users land after signing in.
  def after_update_path_for(resource)
    edit_profile_path
  end
end
