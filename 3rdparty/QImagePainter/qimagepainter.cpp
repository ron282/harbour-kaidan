#include "qimagepainter.h"


ImagePainter::ImagePainter(QQuickItem *parent) :
        QQuickPaintedItem(parent)
{
}

void ImagePainter::setSource(const QImage &source)
{
    m_Image = source;
    emit sourceChanged();
}

QImage ImagePainter::source() const
{
    return m_Image;
}

void ImagePainter::paint(QPainter *painter)
{
    painter->drawImage(QPoint(0,0), m_Image);
}
