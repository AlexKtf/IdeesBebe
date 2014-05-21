$last_message = $("#conversation .comment").last()
$last_message.append("<%= j render(partial: 'messages/message', locals: { message: @message, align: 'left'}) %>").fadeIn()
$('#message_content').val('')
