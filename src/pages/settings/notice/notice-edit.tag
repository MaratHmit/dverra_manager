| import 'components/checkbox-list.tag'

notice-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/notice') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("mails", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? 'Новое уведомление' : 'Редактирование уведомления' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-6: .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .col-md-6: .form-group(class='{ has-error: error.subject }')
                    label.control-label Тема
                    input.form-control(name='subject', type='text', value='{ item.subject }')
                    .help-block { error.subject }
            .row
                .col-md-6: .form-group
                   label.control-label Назначение
                   select.form-control(name='target', value='{ item.target }')
                       option(value='email') Email
                       option(value='sms') SMS
                       option(value='telegram') Telegram
                   .help-block { error.target }
                .col-md-3: .form-group
                    label.control-label Получатель
                    input.form-control(name='recipient', type='text', value='{ item.recipient }')
                .col-md-3: .form-group
                    label.control-label Отправитель
                    input.form-control(name='sender', type='text', value='{ item.sender }')
            .form-group
                label.control-label Триггеры
                checkbox-list(items='{ item.triggers }')
            .form-group
                   label.control-label Шаблон
                   ckeditor(name='content', value='{ item.content }')
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                | Включено

    script(type='text/babel').
        var self = this

        self.loader = false
        self.item = {}

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            target: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.reload = () => {
            observable.trigger('notice-edit', self.item.id)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Notice',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Шаблон уведомления сохранен!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/settings/notice/${self.item.id}`)
                        observable.trigger('notices-reload')
                    }
                })
            }
        }

        observable.on('notice-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true

            API.request({
                object: 'Notice',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.loader = false
                    self.update()
                },
            error(response) {
                self.item = {}
                self.loader = false
                self.update()
                }
            })
        })

        observable.on('notice-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}

             API.request({
                object: 'Trigger',
                method: 'Fetch',
                success: (response, xhr) => {
                    self.item.triggers = response.items
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })