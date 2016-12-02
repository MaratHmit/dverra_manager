| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'pages/images/images-modal.tag'
| import 'pages/images/image-select.tag'

brand-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#products/brands') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование бренда' }
        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#brand-edit-home') Основная информация
            li: a(data-toggle='tab', href='#brand-edit-content') Полное описание
            li: a(data-toggle='tab', href='#brand-edit-seo') SEO
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #brand-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='imagePath', alt='0', size='256', value='{ item.imagePath }')
                        .col-md-10
                            .row
                                .col-md-12
                                    .form-group(class='{ has-error: error.name }')
                                        label.control-label Наименование
                                        input.form-control(name='name', type='text', value='{ item.name }')
                                        .help-block { error.name }
                            .row
                                .col-md-12
                                    .form-group
                                        label.control-label URL страницы
                                        input.form-control(name='url', type='text', value='{ item.url }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Описание
                                textarea.form-control(rows='5', name='description',
                                style='min-width: 100%; max-width: 100%;', value='{ item.description }')

                #brand-edit-content.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                ckeditor(name='content', value='{ item.content }')

                #brand-edit-seo.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Заголовок
                                input.form-control(name='metaTitle', type='text', value='{ item.metaTitle }')
                            .form-group
                                label.control-label Ключевые слова
                                input.form-control(name='metaKeywords', type='text', value='{ item.metaKeywords }')
                            .form-group
                                label.control-label Описание
                                textarea.form-control(rows='5', name='metaDescription',
                                    style='min-width: 100%; max-width: 100%;', value='{ item.metaDescription }')
    script(type='text/babel').
        var self = this

        self.item = {}
        self.loader = false
        self.error = false
        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            self.error = self.validation.validate(self.item, self.rules, e.target.name)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Brand',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Бренд сохранен!', style: 'popup-success'})
                        observable.trigger('brands-reload')
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('brands-edit', self.item.id)
        }

        observable.on('brands-edit', id => {
            self.loader = true
            self.error = false
            var params = {id: id}

            API.request({
                object: 'Brand',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response || {}
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