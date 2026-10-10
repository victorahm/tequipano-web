module ApplicationHelper
  def user_initials(user)
    user.name.to_s.split.map { |word| word[0] }.first(2).join.upcase
  end
end
