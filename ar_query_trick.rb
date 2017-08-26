# Reference: https://medium.com/@apneadiving/active-records-queries-tricks-2546181a98dd

####1. Join query with condition on the associated table ####
# User model
scope :activated, ->{
  joins(:profile).where(profiles: { activated: true })
}
# usually we will use it,

# Profile model
scope :activated, ->{ where(activated: true) }
# User model
scope :activated, ->{ joins(:profile).merge(Profile.activated) }
# With this setup you keep separated concerns and logic

####2. Different nested joins ####
User.joins(:profiles).merge(Profile.joins(:skills))
=> SELECT users.* FROM users
   INNER JOIN profiles    ON profiles.user_id  = users.id
   LEFT OUTER JOIN skills ON skills.profile_id = profiles.id
# So you'd rather use:
User.joins(profiles: :skills)
=> SELECT users.* FROM users
   INNER JOIN profiles ON profiles.user_id  = users.id
   INNER JOIN skills   ON skills.profile_id = profiles.id

####3. Exist query ####
# Post
scope :famous, ->{ where("view_count > ?", 1_000) }
# User
scope :without_famous_post, ->{
  where(_not_exists(Post.where("posts.user_id = users.id").famous))
}
def self._not_exists(scope)
  "NOT #{_exists(scope)}"
end
def self._exists(scope)
  "EXISTS(#{scope.to_sql})"
end

####4. Subqueries ####
Post.where(user_id: User.created_last_month.pluck(:id))
# You could achieve the same result with a single query containing a subquery:
Post.where(user_id: User.created_last_month)
