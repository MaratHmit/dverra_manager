| import 'components/catalog.tag'

requests-list
    catalog(object='Request', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        remove='{ remove }', dblclick='{ edit }', store='requests-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='<=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label Статус заявки
                        select.form-control(data-name='status')
                            option(value='') Все
                            option(value='0') Новые
                            option(value='1') В работе
                            option(value='2') Завершенные
        #{'yield'}(to='head')
            button.btn.btn-warning(if='{ parent.isAllowedStatus }', onclick='{ handlers.createMeasurement }', title='Создать замер', type='button')
                i.fa.fa-check
                |  Замер

        #{'yield'}(to="body")
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='geo') { row.geoLocation }
            datatable-cell(name='ip') { row.ip }
            datatable-cell(name='note') { row.note }
            datatable-cell(name='status', class='{ handlers.statuses.colors[row.status]  } ')
                | { handlers.statuses.text[row.status]  }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Request'
        self.statuses = []
        self.statusesMap = { text: ['Новая', 'В работе', 'Завершенная'], colors: ['bg-danger', 'bg-warning', 'bg-success'] }
        self.isAllowedStatus = false

        self.handlers = {
            statuses: self.statusesMap,
             onSelected(selectedRows) {                
                self.isAllowedStatus = false
                if (selectedRows.length > 0) {
                    let item = selectedRows[0]
                    self.isAllowedStatus = !item.status
                }
            }
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'date' , value: 'Дата' },
            { name: 'name' , value: 'Имя' },
            { name: 'phone' , value: 'Телефон' },
            { name: 'geo' , value: 'ГЕО локация' },
            { name: 'ip' , value: 'IP адрес' },
            { name: 'note' , value: 'Заметка' },
            { name: 'status' , value: 'Статус' },
        ]

        self.edit = function (e) {
          riot.route(`/requests/${e.item.row.id}`)
        }

        observable.on('requests-reload', function () {
            self.tags.catalog.reload()
        })





