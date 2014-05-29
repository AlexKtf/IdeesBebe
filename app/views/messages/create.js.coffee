$last_message = $("#conversation .comment").last()
$last_message.append("<%= j render(partial: 'messages/message', locals: { message: @message, align: 'left'}) %>")
$conversation = $('#conversation')
$conversation.scrollTop($conversation.scrollTop() - $conversation.offset().top + $('.comments .comment:last-child').offset().top)

<% if not @status.can_send_message? current_user %>
$('#conversation-form').fadeOut()
$segment = $('.piled')
<% if @status.closed %>
$segment.append('fermer')
<% else %>
$segment.append('vendu')
<% end %>
<% end %>

$('#message_content').val('').focus()
