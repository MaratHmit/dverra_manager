

notice
    h4 Уведомления

    catalog(object='Notice', cols='{ cols }', reload='true', handlers='{ handlers }',
    add='{ permission(add, "mails", "0100") }',
    remove='{ permission(remove, "mails", "0001") }',
    dblclick='{ permission(noticeOpen, "mails", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='subject') { row.subject }
            datatable-cell(name='recipient') { row.recipient }
            datatable-cell(name='sender') { row.sender }
            datatable-cell(name='target') { row.target }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')

        self.collection = 'Notice'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'subject', value: 'Тема'},
            {name: 'recipient', value: 'Получатель'},
            {name: 'sender', value: 'Отправитель'},
            {name: 'target', value: 'Назначение'},
        ]

        self.add = () => riot.route('settings/notice/new')

        self.noticeOpen = e => riot.route(`settings/notice/${e.item.row.id}`)

        observable.on('notices-reload', () => {
            self.tags.catalog.reload()
        })
