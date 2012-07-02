$.extend(
	{
		getUrlVars: function()
		{
			var vars = [], hash;
			var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
			for (var i = 0; i < hashes.length; i++)
			{
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
			return vars;
		},
		getUrlVar: function(name)
		{
			return $.getUrlVars()[name];
		}
	}
);

$(document).ready(function()
{
	if ($.getUrlVar('fail'))
	{
		$('#loginMessage').slideDown();
		$('#loginMessage').addClass('error');
		$('#loginMessage').removeClass('success');
		$('#loginMessage').html('<img src="/_img/site/loginError.png" /><span style="position: relative; top: -20px">Login Failed!</span>');
	}
	$('.form input').focus(function()
		{
			$('#loginMessage').slideUp();
		}
	);
});
