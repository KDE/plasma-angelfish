/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

//#define KDE_DEPRECATED 1

#include "completionmodel.h"
#include "completionitem.h"
#include "history.h"

// Nepomuk
#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>
//#include <nepomuk2/queryparser.h>
#include <Nepomuk2/Query/ResourceTerm>
#include "bookmark.h"

#include <Nepomuk2/Query/Query>
//#include <Nepomuk2/Query/FileQuery>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Query/Result>

//#include <soprano/vocabulary.h>

#include <nepomuk2/andterm.h>
#include <nepomuk2/orterm.h>
#include <nepomuk2/comparisonterm.h>
#include <nepomuk2/literalterm.h>
#include <nepomuk2/resourcetypeterm.h>

#include "kdebug.h"

class CompletionModelPrivate {

public:
    QList<QObject*> items;
    QList<QObject*> filteredItems;
    Nepomuk2::Query::Query query;
    Nepomuk2::Query::QueryServiceClient* queryClient;
    History* history;
    QString filter;
    bool isPopulated;
};


CompletionModel::CompletionModel(QObject *parent)
    : QObject(parent)
{
    d = new CompletionModelPrivate;
    d->isPopulated = false;
    d->history = new History(this);
    connect(d->history, SIGNAL(dataChanged()), this, SIGNAL(dataChanged()));
}

CompletionModel::~CompletionModel()
{
    delete d;
}

History* CompletionModel::history()
{
    return d->history;
}

QList<QObject*> CompletionModel::items()
{
    QList<QObject*> l;
    l.append(d->history->items());
    l.append(d->items);

    return l;
}

QList<QObject*> CompletionModel::filteredBookmarks()
{
    return filteredItems(d->items);
}

QList<QObject*> CompletionModel::filteredHistory()
{
    return filteredItems(d->history->items());
}

QList<QObject*> CompletionModel::filteredItems(const QList<QObject*> &l)
{
    //QList<QObject*> l;
    //l.append(d->history->items());
    //l.append(d->items);
    if (d->filter.isEmpty()) {
        return l;
    }
    d->filteredItems.clear();
    QList<QObject*> filteredItems;
    foreach(QObject* it, l) {
        CompletionItem* ci = qobject_cast<CompletionItem*>(it);
        if (ci) {
            // Matching, pretty basic right now
            if (ci->name().contains(d->filter, Qt::CaseInsensitive)) {
                filteredItems.append(ci);
            } else if (ci->url().contains(d->filter, Qt::CaseInsensitive)) {
                filteredItems.append(ci);
            }
        }
    }

    return filteredItems;
}

void CompletionModel::setFilter(const QString &filter)
{
    d->filter = filter;
    //kDebug() << "OOO FIlter set to " << filter;
    emit dataChanged();
}

void CompletionModel::populate()
{
    //kDebug() << "populating model...";
    if (!d->isPopulated) {
        d->isPopulated = true;
        d->history->loadHistory();
        loadBookmarks();
    }
}

void CompletionModel::loadBookmarks()
{
    if (!Nepomuk2::Query::QueryServiceClient::serviceAvailable()) {
        return;
    }

    kDebug() << "Loading bookmarks...";
    Nepomuk2::Types::Class bookmarkClass(Nepomuk2::Bookmark::resourceTypeUri());
    Nepomuk2::Query::ResourceTypeTerm rtt(bookmarkClass);

    d->query.setTerm(rtt);

    d->queryClient = new Nepomuk2::Query::QueryServiceClient(this);

    connect(d->queryClient, SIGNAL(finishedListing()),
            this, SLOT(finishedListing()));
    connect(d->queryClient, SIGNAL(newEntries(QList<Nepomuk2::Query::Result>)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>)));
    connect(d->queryClient, SIGNAL(entriesRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));

    d->query.setLimit(64);
    d->queryClient->query(d->query);
}

void CompletionModel::finishedListing()
{
    //kDebug() << "Done listing.";
}



void CompletionModel::newEntries(const QList< Nepomuk2::Query::Result >& entries)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        CompletionItem* item = new CompletionItem(this);
        item->setResource(res.resource());
        d->items.append(item);
    }

    emit dataChanged();
}

void CompletionModel::entriesRemoved(const QList< QUrl >& urls)
{
    // not efficient but I do think users will have thousands of bookmarks to make this cause any lag.
    // Also in the common case urls.size() == 1, so there will be only one iteration through the
    // bookmarks list.
    QMutableListIterator<QObject*> i(d->items);
    foreach (const QUrl &u, urls) {
        while (i.hasNext()) {
            CompletionItem * cItem = static_cast<CompletionItem *>(i.next());
            if (cItem && cItem->resourceUri() == u) {
                //kDebug() << "Removing" << u << cItem->url();
                i.remove();
                cItem->deleteLater();
                break;
            }
        }
        i.toFront();
    }
    emit dataChanged();
}

#include "completionmodel.moc"
