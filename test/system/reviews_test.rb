require "application_system_test_case"

class ReviewsTest < ApplicationSystemTestCase
  setup do
    @review = reviews(:one)
  end

  test "visiting the index" do
    visit reviews_url
    assert_selector "h1", text: "Reviews"
  end

  test "should create review" do
    visit reviews_url
    click_on "New review"

    fill_in "Book", with: @review.book_id
    fill_in "Number of upvotes", with: @review.number_of_upvotes
    fill_in "Review", with: @review.review
    fill_in "Score", with: @review.score
    click_on "Create Review"

    assert_text "Review was successfully created"
    click_on "Back"
  end

  test "should update Review" do
    visit review_url(@review)
    click_on "Edit this review", match: :first

    fill_in "Book", with: @review.book_id
    fill_in "Number of upvotes", with: @review.number_of_upvotes
    fill_in "Review", with: @review.review
    fill_in "Score", with: @review.score
    click_on "Update Review"

    assert_text "Review was successfully updated"
    click_on "Back"
  end

  test "should destroy Review" do
    visit review_url(@review)
    click_on "Destroy this review", match: :first

    assert_text "Review was successfully destroyed"
  end
end
