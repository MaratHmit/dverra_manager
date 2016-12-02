| import 'components/catalog.tag'
| import 'lodash/lodash'
| import 'components/star-rating.tag'

reviews-list

    catalog(object='Review', cols='{ cols }', reload='true', search='true', sortable='true',
    add='{ permission(add, "reviews", "0100") }',
    remove='{ permission(remove, "reviews", "0001") }',
    dblclick='{ permission(open, "reviews", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='dateDisplay') { row.dateDisplay }
            datatable-cell(name='productName') { row.productName }
            datatable-cell(name='userName') { row.userName }
            datatable-cell(name='mark')
                star-rating(count='5', value='{ row.mark }')
            datatable-cell(name='likes') { row.likes }
            datatable-cell(name='dislikes') { row.dislikes }
            datatable-cell(name='commentary') { _.truncate(row.commentary.replace( /<.*?>/g, '' ), {length: 50}) }
            datatable-cell(name='merits') { _.truncate(row.merits.replace( /<.*?>/g, '' ), {length: 50}) }
            datatable-cell(name='demerits') { _.truncate(row.demerits.replace( /<.*?>/g, '' ), {length: 50}) }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Review'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'dateDisplay', value: 'Дата'},
            {name: 'productName', value: 'Наименование товара'},
            {name: 'userName', value: 'Пользователь'},
            {name: 'mark', value: 'Звёзд'},
            {name: 'likes', value: 'Лайков'},
            {name: 'dislikes', value: 'Дислайков'},
            {name: 'commentary', value: 'Отзыв'},
            {name: 'merits', value: 'Достоинства'},
            {name: 'demerits', value: 'Недостатки'}
        ]

        self.add = e => riot.route(`/reviews/new`)

        self.open = e => riot.route(`/reviews/${e.item.row.id}`)

        observable.on('reviews-reload', () => self.tags.catalog.reload())


