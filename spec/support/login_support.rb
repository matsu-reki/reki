module LoginSupport

  #
  # 指定したユーザでログインセッションを作る
  #
  def login(user)
    session[:current_user] = user.id
  end

end
