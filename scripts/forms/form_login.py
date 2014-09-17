import scripts.classes.class_form as form

def get_form():
	form_fields = [
		{
			'type': 'email',
			'name': 'email',
			'class': 'form-control',
			'placeholder': 'Email Address',
			'after-field': '<br>',
			'required': True,
			'autofocus': True,
		},
		{
			'type': 'password',
			'name': 'password',
			'class': 'form-control',
			'placeholder': 'Password',
			'after-field': '<br>',
			'required': True
		},
		{
			'type': 'checkbox',
			'name': 'remember-me',
			'id': 'remember-me',
			'options': [
				{
					'value': 'remember-me',
					'label': 'Remeber me'
				}
			],
			'after-field': '<br>',
		},
		{
			'type': 'submit',
			'name': 'btnSubmit',
			'class': 'btn btn-lg btn-primary btn-block',
			'value': 'Sign in'
		}
	]

	login_form = form.Form('login-form', 'form-signin form', 'form-login')
	login_form.setFields(form_fields)
	login_form.generateForm()

	return login_form.getGeneratedForm()


