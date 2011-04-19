require File.dirname(__FILE__) + '/../test_helper'

class ResetPasswordRequestsControllerTest < ActionController::TestCase
  context "Permissions" do
     should_require_no_user_on [:new, :create, :edit, :update]
  end

  context "Users Routes" do
    # Test that route exists
    should_route :get,  "/reset_password_requests/new",    :action => :new
    should_route :post, "/reset_password_requests",        :action => :create
    should_route :get,  "/reset_password_requests/1/edit", :action => :edit,   :id => 1
    should_route :put,  "/reset_password_requests/azerty", :action => :update, :id => "azerty"
  end

  # ----------------------------------------------------------------------------------------------------------------
  # Not logged User
  # ----------------------------------------------------------------------------------------------------------------
  context "If I'm an unlogged user" do
    context "and do GET to :new" do
      setup do
        get :new
      end
      should_respond_with :success
      should_render_template :new
    end

    context "and do POST to :create" do
      setup do
        @organization = Factory(:organization)
        @testuser = Factory.build(:user)
        @testuser.save_without_session_maintenance
      end

      context "with a valid user's e-mail" do
        setup do
          post :create, :email => @testuser.email
        end
        should_respond_with :ok
        should_assign_to(:user){ @testuser }
        should_render_template :create
      end

      context "with an invalid e-mail" do
        setup do
          post :create, :email => "test@something.com"
        end
        should_respond_with :ok
        should_not_assign_to(:user){ @testuser }
        should_render_template :create
      end
    end

    context "and do GET to :edit" do
      setup do
        @organization = Factory(:organization)
        @testuser = Factory.build(:user)
        @testuser.save_without_session_maintenance
      end

      context "with a valid perishable token" do
        setup do
          get :edit, :id => @testuser.perishable_token
        end
        should_respond_with :ok
        should_assign_to(:user){ @testuser }
        should_render_template :edit
      end

      context "with an invalid perishable token" do
        setup do
          get :edit, :id => "azerty123456789"
        end
        should_respond_with :ok
        should_not_assign_to(:user)
        should_render_template :edit
      end
    end

    context "and I do PUT on :update" do
      context "with a valid perishable token" do
        setup do
          @organization = Factory(:organization)
          @testuser = Factory.build(:user)
          @testuser.save_without_session_maintenance
        end
        context "and matching passwords" do
          setup do
            put :update, :id => @testuser.perishable_token, :user => {:password => 'secret', :password_confirmation => 'secret'}
          end
          should_respond_with :redirect
          should_assign_to(:user){ @testuser }
          should_redirect_to("root_url"){ root_url }
          should_set_the_flash_to("Password successfully reset")
        end
        context "with unmatching passwords" do
           setup do
            put :update, :id => @testuser.perishable_token, :user => { :password => 'secret', :password_confirmation => 'nosecret'}
          end
          should_respond_with :ok
          should_assign_to(:user){ @testuser }
          should_render_template :edit
          should_set_the_flash_to("Passwords do not match.")
        end
      end

      context "with an invalid perishable token" do
        setup do
          @organization = Factory(:organization)
          @testuser = Factory.build(:user)
          @testuser.save_without_session_maintenance
          put :update, :id => "azerty123456789", :user => { :password => 'secret', :password_confirmation => 'secret' }
        end
        should_respond_with :redirect
        should_not_assign_to(:user)
        should_redirect_to("root_url"){ root_url }
        should_set_the_flash_to("Invalid token")
      end
    end
  end

  # ----------------------------------------------------------------------------------------------------------------
  # Logged in User
  # ----------------------------------------------------------------------------------------------------------------

  context "If I am a logged in user" do
    setup do
      @organization = Factory(:organization)
      @testuser = Factory(:user)
    end

    context "and do GET to :new" do
      setup do
        get :new
      end
      should_set_the_flash_to("Please Logout")
      should_redirect_to("account url"){ account_url }
    end

    context "and do POST to :create" do
      setup do
        post :create, :email => @testuser.email
      end
      should_set_the_flash_to("Please Logout")
      should_redirect_to("account url"){ account_url }
    end

    context "and do GET to :edit" do
      setup do
        get :edit, :id => @testuser.perishable_token
      end
      should_set_the_flash_to("Please Logout")
      should_redirect_to("account url"){ account_url }
    end

    context "and do PUT to :update" do
      setup do
        put :update, :id => @testuser.perishable_token, :user => { :password => 'secret', :password_confirmation => 'secret' }
      end
      should_set_the_flash_to("Please Logout")
      should_redirect_to("account url"){ account_url }
    end
  end
end
