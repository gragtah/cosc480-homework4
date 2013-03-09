require 'spec_helper'

describe MoviesController do

  describe "should sort the movies on the main page" do
    it "should sort the movies by title" do
      get :index, {:sort => "title"}
      session[:sort].should == "title"
    end
    it "should sort the movies by release date" do
      get :index, {:sort => "release_date"}
      session[:sort].should == "release_date"
    end
  end
  
  describe "restrict by ratings" do
    it "should only show movies with selected ratings" do
      get :index, {:ratings => ["G", "PG"]}
      session[:ratings].should == ["G", "PG"]
    end
  end

  describe "add director to existing movie" do
    it "should call update and redirect to movies" do
      @movie = mock(Movie, :title => "The Social Network", :director => "David Fincher",
                                         :release_date => "31-Oct-2009",:id => 0) 
      Movie.stub!(:find).with("0").and_return(@movie)
      @movie.stub!(:update_attributes!).and_return(true)
      put :update, {:id => "0"}
      response.should redirect_to(movie_path(@movie))
      end
  end

  describe "create a movie" do
    it "should create a new movie and redirect to movies list" do
      post :create, {:title => "testMovie", :director => "Gaurav", :id => 0}
      response.should redirect_to(movies_path)
    end
  end
  
  describe "show a movie" do
    it "should show movie details" do
      fake_movie = mock("movie")
      Movie.should_receive(:find).with("0").and_return(fake_movie)
      get :show, {:id => 0}
    end
  end

  describe "should edit a movie" do
    it 'should allow editing of a movie' do
	fake_movie = mock("movie")
	Movie.should_receive(:find).with("1").and_return(fake_movie)
	get :edit, {:id => 1}
    end
  end

  describe "delete a movie" do
    it "should delete the correct movie and redirect to movies" do
      @movie = mock(Movie, :title => "JustAnotherFakeMovie", :rating => "G", :id =>"2")
      Movie.stub!(:find).with("2").and_return(@movie)
      @movie.should_receive(:destroy)
      delete :destroy, {:id => "2"}
      response.should redirect_to(movies_path)
    end
  end

  describe "oddness should return odd or even depending on input" do
    class FakeClass
    end
    it "should call the oddness function" do
	dummy = FakeClass.new
	dummy.extend(MoviesHelper)
	dummy.oddness(5).should == "odd"
    end
  end

  describe "movies with same director" do
    it "should find movies with the same director - happy path" do
      movie_1 = mock(Movie, :title => "Gaurav movie 1", :director => "Gaurav", :id => "0")
      movie_2 = mock(Movie, :title => "Gaurav movie 2", :director => "Gaurav", :id => "1")
      Movie.stub!("find").with("0").and_return(movie_1)
      Movie.should_receive(:find_all_by_director).with("Gaurav").and_return([movie_1, movie_2])
      get :same_director, {:id =>"0"}
    end
    it "should flash 'movie has no director info' - sad path" do
      movie = mock(Movie, :title => "Gaurav movie", :director => "", :id => "0")
      Movie.stub!("find").with("0").and_return(movie)
      get :same_director, {:id =>"0"}
      flash[:notice].should == "\'Gaurav movie\' has no director info"
    end
  end

end
