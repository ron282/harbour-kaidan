#pragma once

#include <QImage>
#include <QQuickPaintedItem>
#include <QVariant>
#include <QPainter>

class ImagePainter : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QImage source READ source WRITE setSource NOTIFY sourceChanged)

public:

    ImagePainter(QQuickItem *parent = nullptr);

    void setSource(const QImage &source);
    QImage source() const;

    virtual void paint(QPainter *painter);

Q_SIGNALS:
    void sourceChanged();

private:
    QImage m_Image;
};
