comment-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#comments') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("comments", "0100") : checkPermission("comments", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Комментарий к товару:
            b {item.nameProduct}

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата
                        datetime-picker.form-control(name='date', format='DD.MM.YYYY HH:mm', value='{ item.dateDisplay }')
                .col-md-4
                    .form-group(class='{ has-error: error.idProduct }')
                        label.control-label Товар
                        .input-group
                            a.input-group-addon(if='{ item.idProduct }', href='#products/{ item.idProduct }', target='_blank')
                                i.fa.fa-eye
                            input.form-control(name='productName', type='text', value='{ item.productName }', readonly)
                            span.input-group-addon(onclick='{ changeProduct }')
                                i.fa.fa-list
                        .help-block { error.idProduct }
                .col-md-4
                    .form-group(class='{ has-error: (error.idUser) }')
                        label.control-label Автор комментария
                        .input-group
                            a.input-group-addon(if='{ item.idUser }',
                            href='{ "#persons/" + item.idUser }', target='_blank')
                                i.fa.fa-eye
                            input.form-control(name='idUser',
                                value='{ item.idUser ? item.idUser + " - " + item.userName : "" }', readonly)
                            span.input-group-addon(onclick='{ changePerson }')
                                i.fa.fa-list
                        .help-block { error.idUser }
                .col-md-2
                    .form-group(class='{ has-error: error.userEmail }')
                        label.control-label Email
                        input.form-control(name='userEmail', type='text', value='{ item.userEmail }', readonly)
                        .help-block { error.userEmail }
            .row
                .col-md-12
                    .form-group
                        label.control-label Комментарий
                        textarea.form-control(rows='5', name='commentary',
                        style='min-width: 100%; max-width: 100%;', value='{ item.commentary }')
            .row
                .col-md-12
                    .form-group
                        label.control-label
                            b Ответ администратора
                        textarea.form-control(rows='5', name='response',
                        style='min-width: 100%; max-width: 100%;', value='{ item.response }')
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isActive', type='checkbox', checked='{ item.isActive }')
                                | Отображать комментарий на сайте


    script(type='text/babel').
        var self = this

        self.item = {
            isActive: 1
        }

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            idProduct: 'empty',
            idUser: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)
            if (!self.error) {
                API.request({
                    object: 'Comment',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        if (self.isNew)
                            riot.route(`/comments/${self.item.id}`)
                        self.update()
                        observable.trigger('comments-reload')
                    }
                })
            }
        }

        self.changePerson = () => {
            modals.create('persons-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idUser = items[0].id
                        self.item.userName = items[0].name
                        self.item.userEmail = items[0].email
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.changeProduct = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idProduct = items[0].id
                        self.item.productName = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        observable.on('comment-edit', id => {
            var params = {id}
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Comment',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                },
                error(response) {
                    self.item = {}
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })

        observable.on('comment-new', () => {
            self.isNew = true
            self.item = {
                isActive: 1
            }
            self.update()
        })

        self.reload = () => {
            observable.trigger('comment-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })