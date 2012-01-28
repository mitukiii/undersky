###
# Undersky Definition
###

class Undersky
  undersky = this
  $w = $(window)
  $d = $(document)

  class Growl
    top = ->
      $('.alert-message.growl').size() * 34 + 40;

    @show: (text, level) ->
      level ||= 'info'
      growl = $('<div class="alert-message growl ' + level + '">' + text + '</div>')
      growl.css('top', top() + 'px')
      $(document.body).append(growl)
      growl.alert().hide().slideDown()
      setTimeout(->
        growl.slideUp ->
          growl.remove()
      , 3000)

  class Spinner
    constructor: (element) ->
      @element = element
      @spinner = $('<div class="spinner"><img src="/assets/spinner.gif"></div>')

    show: ->
      @spinner.css
        width: @element.width(),
        height: @element.height()
      @element.before(@spinner)
      @element.hide()
      @spinner.show()

    hide: ->
      @spinner.hide()
      @element.show()

    remove: ->
      @element.remove()
      @spinner.remove()

  class Search
    self = this

    @submit: (e) ->
      e && e.preventDefault()
      form = $(this);
      name = form.find('[name="name"]').val()
      url = '/search'
      if name
        url += '/' + name
      location.href = url

    do ->
      $('form[action="/search"]').live 'submit', self.submit

  class MediaGrid
    self = this

    @columns: ->
      $('.media-grid.photos a')

    @toggle: (e) ->
      return if e.hasModifierKey()
      e && e.preventDefault()
      panels = $('.modal.media-panel')
      panels.filter('.show').hide()
      columns = self.columns()
      column = $(this)
      id = column.data('id')
      actived = column.hasClass('actived')
      columns.filter('.actived, .focused').removeClass('actived').removeClass('focused')
      column.addClass('focused').focus()
      unless actived
        column.addClass('actived')
        panels.filter('[data-id="' + id + '"]').show()
        self.resize()
        if columns.size() - columns.index(column) < 10
          $('.page-button.next-page a').click()

    @close: (e) ->
      e && e.preventDefault()
      columns = self.columns()
      columns.filter('.actived').removeClass('actived')
      panels = $('.modal.media-panel')
      panels.filter('.show').hide()

    @action: (e) ->
      return if e.hasModifierKey()
      return if $(e.target).isInput()
      switch e.which
        when 37, 75 # ←, k
          self.prev(e)
        when 39, 74 # →, j
          self.next(e)

    @prev: (e) ->
      columns = self.columns()
      column = columns.filter('.focused')
      if column.size()
        column = column.parent().prev().find('a').first()
      if column.size()
        self.toggle.call(column, e)
        $w.scrollTop(column.offset().top - 65)

    @next: (e) ->
      columns = self.columns()
      column = columns.filter('.focused')
      if column.size()
        column = column.parent().next().find('a').first()
      else
        column = columns.first()
      if column.size()
        self.toggle.call(column, e)
        $w.scrollTop(column.offset().top - 65)

    @resize: ->
      $('.modal.media-panel.show').css('height', $w.height() - 75)

    do ->
      $w.resize self.resize
      $d.delegate '.media-grid.photos a', 'click', self.toggle
      $d.delegate '.modal.media-panel .close', 'click', self.close
      $d.keydown self.action

  class Likes
    self = this

    @likesHandler:
      beforeSend: (e) ->
        self = $(this)
        spinner = new Spinner self
        spinner.show()
        self.data('spinner', spinner)
      success: (e, data) ->
        self = $(this)
        container = self.parents('.likes').find('.likes-data')
        container.children().remove()
        spinner = self.data('spinner')
        spinner.remove()
        container.before('<div class="likes-count"><span class="count">' + data.length + '</span> likes</div>')
        for u in data
          username = $('<span class="data-container" data-username="' + u.username + '"></span>')
          username.append('<span class="username"><a href="/users/' + u.id + '">' + u.username + '</a></span>');
          username.append(', ')
          container.append(username)
      error: (e, data) ->
        self = $(this)
        spinner = self.data('spinner')
        spinner.hide()
        Growl.show('likes load failed', 'error')

    @likesStatusHandler:
      beforeSend: (e) ->
        $(this).disableElement()
      complete: (e, data) ->
        $(this).enableElement()

    @likeHandler:
      success: (e, data) ->
        self = $(this)
        user = $d.data('user')
        status = $(this).parents('.likes-status')
        status.removeClass('unlike').addClass('like')
        panel = self.parents('.modal.media-panel')
        panel.find('.likes-count .count').incText()
        username = $('<div class="group" data-username="' + user.username + '"></div>')
        username.append('<img src="' + user.profile_picture + '" class="profile-picture" />')
        username.append('<span class="data-container" ></span>')
        username.append('<span class="username"><a href="/users/' + user.id + '">' + user.username + '</a></span>');
        panel.find('.likes-data').append(username)
      error: (e, data) ->
        Growl.show('like failed', 'error')

    @unlikeHandler:
      success: (e, data) ->
        self = $(this)
        user = $d.data('user')
        status = self.parents('.likes-status')
        status.removeClass('like').addClass('unlike')
        panel = self.parents('.modal.media-panel')
        panel.find('.likes-count .count').decText()
        panel.find('.likes-data [data-username="' + user.username + '"]').remove()
      error: (e, data) ->
        Growl.show('unlike failed', 'error')

    @action: (e) ->
      return if e.hasModifierKey()
      return if $(e.target).isInput()
      return if e.which != 76 # l
      panel = $('.modal.media-panel.show')
      return if panel.size() == 0
      e && e.preventDefault()
      likes_status = panel.find('.likes-status')
      if likes_status.hasClass('like')
        likes_status.find('.likes-button.unlike a').click()
      else
        likes_status.find('.likes-button.like a').click()

    do ->
      $('.likes-load-link a').bindAjaxHandler self.likesHandler
      $('.likes-button a').bindAjaxHandler self.likesStatusHandler
      $('.likes-button.like a').bindAjaxHandler self.likeHandler
      $('.likes-button.unlike a').bindAjaxHandler self.unlikeHandler
      $d.keydown self.action

  class Comments
    self = this

    @commentsHandler:
      beforeSend: (e) ->
        self = $(this)
        spinner = new Spinner self
        spinner.show()
        self.data('spinner', spinner)
      success: (e, data) ->
        self = $(this)
        container = self.parents('.comments')
        container.children().remove()
        container.append(data)
      error: (e, data) ->
        self = $(this)
        spinner = self.data('spinner')
        spinner.hide()
        Growl.show('comments load failed', 'error')

    @deleteCommentHandler:
      beforeSend: (e) ->
        $(this).__hide()
      success: (e, data) ->
        self = $(this)
        panel = self.parents('.modal.media-panel')
        if panel.find('.comments-count .count').decText().intText() == 0
          panel.find('.comments').remove()
        else
          self.parents('.comment').remove()
      error: (e, data) ->
        $(this).__show()
        Growl.show('delete comment failed', 'error')

    do ->
      $('.comments-load-link a').bindAjaxHandler self.commentsHandler
      $('.comments-button.delete-comment a').bindAjaxHandler self.deleteCommentHandler

    class CreateComment
      self = this

      @show: (e) ->
        e && e.preventDefault()
        container = $('.modal.create-comment')
        if container.size() > 0
          return container.find('textarea').focus()
        self = $(this)
        panel = self.parents('.modal.media-panel')
        caption_data = panel.find('.caption').children()
        comments_data = panel.find('.comments-data').children()
        container = $('<div class="modal create-comment" data-id="' + panel.data('id') + '"></div>')
        form = $('<form action="' + self.attr('href') + '" method="post" data-remote="true"></form>')
        header = $('<div class="modal-header">comment</div>')
        body = $('<div class="modal-body"><textarea name="text" rows="4" cols="50" required="required"></textarea></div>')
        footer = $('<div class="modal-footer"></div>')
        footer.append('<div class="pull-left"><input class="btn primary" name="commit" type="submit" value="comment" disabled="disabled" /></div>')
        footer.append('<div class="pull-left"><input class="btn" name="cancel" type="reset" value="cancel" /></div>')
        form.append(header, body, footer)
        if caption_data.size() > 0
          caption = $('<div class="modal-footer caption"></div>')
          caption.append(caption_data.clone())
          form.append(caption)
        if comments_data.size() > 0
          comments = $('<div class="modal-footer comments"></div>')
          comments.append(comments_data.clone())
          comments.find('.comments-button.delete-comment').remove()
          form.append(comments)
        container.append(form)
        container.modal(show: true)
        container.bind('hidden', -> container.remove())
        container.find('textarea').focus()

      @reply: (e) ->
        e && e.preventDefault()
        self = $(this)
        username = '@' + $(this).text() + ' ';
        textarea = self.parents('.modal.create-comment').find('textarea')
        textarea.focus()
        textarea.val(username + textarea.val().replace(username, ''))

      @validate: (e) ->
        self = $(this)
        commit = $(this).parents('.modal.create-comment').find('[name="commit"]')
        if self.val().length > 0
          commit.enableElement()
        else
          commit.disableElement()

      @hide: (e) ->
        e && e.preventDefault()
        $(this).parents('.modal.create-comment').modal(show: false)

      @handler:
        beforeSend: (e) ->
          self = $(this)
          self.find('input, textarea').each(-> $(this).disableElement())
        success: (e, data) ->
          self = $(this)
          panel = do ->
            container = self.parents('.modal.create-comment')
            container.modal(show: false)
            $('[data-id="' + container.data('id') + '"]')
          return if panel.size() == 0
          container = panel.find('.comments-data')
          if container.size() == 0
            comments = $('<div class="modal-footer comments"></div>')
            count = $('<div class="comments-count"></div>')
            count.append('<span class="count">1</span> comments</span>')
            container = $('<div class="comments-data"></div>')
            comments.append(count, container)
            caption = panel.find('.caption')
            if caption.size() > 0
              caption.after(comments)
            else
              panel.find('.status').after(comments)
          else
            panel.find('.comments-count .count').incText()
          container.append(data)
        error: (e, ddata) ->
          Growl.show('comment request failed', 'error')
        complete: (e, data) ->
          self = $(this)
          self.find('input, textarea').each(-> $(this).enableElement())

      @action: (e) ->
        return if e.hasModifierKey()
        return if $(e.target).isInput()
        return if e.which != 67 # c
        panel = $('.modal.media-panel.show')
        return if panel.size() == 0
        e && e.preventDefault()
        panel.find('.comments-button.create-comment a').click()

      do ->
        $d.delegate '.comments-button.create-comment a', 'click', self.show
        $d.delegate '.modal.create-comment .username a', 'click', self.reply
        $d.delegate '.modal.create-comment [name="text"]', 'keyup change', self.validate
        $d.delegate '.modal.create-comment [name="cancel"]', 'click', self.hide
        $('.modal.create-comment form').bindAjaxHandler self.handler
        $d.keydown self.action

  class Relationships
    self = this

    @outgoingStatusHandler:
      beforeSend: (e) ->
        $(this).disableElement()
      success: (e, data) ->
        status = $(this).parents('.outgoing-status')
        status.removeClass().addClass('outgoing-status').addClass(data.outgoing_status)
      complete: (e, data) ->
        $(this).enableElement()

    @followHandler:
      error: (e, data) ->
        Growl.show('follow request failed', 'error')

    @unfollowHandler:
      error: (e, data) ->
        Growl.show('unfollow request failed', 'error')

    do ->
      $('.relationships-button a').bindAjaxHandler self.outgoingStatusHandler
      $('.relationships-button.follow a').bindAjaxHandler self.followHandler
      $('.relationships-button.unfollow a').bindAjaxHandler self.unfollowHandler

  class Page
    self = this

    @nextPageHandler:
      beforeSend: (e) ->
        $(this).disableElement()
      success: (e, data) ->
        self = $(this)
        data = $(data)
        $('.media-grid').append(data.find('.media-grid > *'))
        $('.modal-container').append(data.find('.modal-container > *'))
        self.replaceWith(data.find('.page-button.next-page a'))
      error: (e, data) ->
        $(this).enableElement()
        Growl.show('next page request failed', 'error')

    do ->
      $('.page-button.next-page a').bindAjaxHandler self.nextPageHandler

new Undersky
