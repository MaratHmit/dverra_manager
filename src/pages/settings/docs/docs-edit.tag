docs-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/docs') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("mails", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { 'Редактирование шаблона' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-6: .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
            .form-group
                label.control-label Шаблон документа
                ckeditor(name='content', value='{ item.content }')

    script(type='text/babel').
        var self = this

        self.loader = false
        self.item = {}

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.reload = () => {
            observable.trigger('docs-edit', self.item.id)
        }

        observable.on('docs-edit', id => {
            let params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'DocTemplate',
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

        self.submit = () => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'DocTemplate',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Шаблон документа сохранен!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        observable.trigger('docTemplate-reload')
                    }
                })
            }
        }

