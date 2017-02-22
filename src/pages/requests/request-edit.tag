| import 'components/loader.tag'

request-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')

        .btn-group
            a.btn.btn-default(href='#requests') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { 'Заявка # ' + item.id }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата заявки
                        input.form-control(name='date',
                            value='{ item.dateDisplay }', readonly)
                .col-md-2
                    .form-group
                        label.control-label Статус
                        select.form-control(name='status')
                            option(value='0', selected='{ item.status == 0 }') Новая
                            option(value='1', selected='{ item.status == 1 }') В работе
                            option(value='2', selected='{ item.status == 2 }') Завершенная
                .col-md-4
                    .form-group
                        label.control-label Имя
                        input.form-control(name='name', value='{ item.name }')
                .col-md-4
                    .form-group
                        label.control-label Телефон
                        input.form-control(name='phone', value='{ item.phone }')
            .row
                .col-md-2
                    .form-group
                        label.control-label IP адрес
                        input.form-control(name='ip', value='{ item.ip }', readonly='true')
                .col-md-10
                    .form-group
                        label.control-label ГЕО локация
                        input.form-control(name='geoLocation', value='{ item.geoLocation }', readonly='true')
            .row
                .col-md-12
                    .form-group
                        label.control-label User-agent
                        input.form-control(name='userAgent', value='{ item.userAgent }', readonly='true')
            .row
                .col-md-12
                    .form-group
                        label.control-label Заметка
                        input.form-control(name='note', value='{ item.note }')



    script(type='text/babel').
        var self = this,
            route = riot.route.create()


        self.mixin('change')

        self.isNew = false
        self.item = {}

        self.reload = e => {
            observable.trigger('request-edit', self.item.id)
        }

        observable.on('request-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Request',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.loader = false
                    self.update()
                }
            })
        })

        self.submit = () => {
            var params = self.item
            API.request({
                object: 'Request',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    self.isNew = false
                    self.update()
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    observable.trigger('requests-reload')
                }
            })
        }

        self.on('mount', () => {
            riot.route.exec()
        })

