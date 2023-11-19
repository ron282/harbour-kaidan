/****************************************************************************
**
** Copyright (C) 2019 René J.V. Bertin <gmail:rjvbertin>
** Copyright (C) 2017 Klarälvdalens Datakonsult AB, a KDAB Group company, info@kdab.com, author Marc Mutz <marc.mutz@kdab.com>
** Copyright (C) 2016 The Qt Company Ltd.
** Copyright (C) 2016 Intel Corporation.
** Contact: gmail:rjvbertin
**
** This file is an extension for the QtCore module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QEMUSTRINGVIEW_H
#define QEMUSTRINGVIEW_H

#include <QString>
class QStringView;

#if defined(QSTRINGVIEW_H) && defined(QSTRINGVIEW_EMULATE)
#warning "QEmuStringView will override Qt's QStringView class!"
#elif !defined(QSTRINGVIEW_H) && !defined(QSTRINGVIEW_EMULATE)
#warning "#define QSTRINGVIEW_EMULATE to emulate QStringView with QEmuStringView"
#endif

#include <QDebug>

#ifdef __SSE2__
#include <immintrin.h>
#endif
#include <qalgorithms.h>
#include <qglobal.h>

#if !defined(Q_ASSERT10)
#  if defined(QT_NO_DEBUG) && !defined(QT_FORCE_ASSERTS)
#    define Q_ASSERT10(cond) static_cast<void>(false && (cond))
#  else
#    define Q_ASSERT10(cond) ((cond) ? static_cast<void>(0) : qt_assert(#cond, __FILE__, __LINE__))
#  endif
#endif

/*
  quintptr and qptrdiff is guaranteed to be the same size as a pointer, i.e.

      sizeof(void *) == sizeof(quintptr)
      && sizeof(void *) == sizeof(qptrdiff)
*/
template <int> struct QIntegerForSize;
typedef QIntegerForSize<Q_PROCESSOR_WORDSIZE>::Signed qregisterint;
typedef QIntegerForSize<Q_PROCESSOR_WORDSIZE>::Unsigned qregisteruint;
typedef QIntegerForSizeof<void*>::Unsigned quintptr;
typedef QIntegerForSizeof<void*>::Signed qptrdiff;
typedef qptrdiff qintptr;
using qsizetype = QIntegerForSizeof<std::size_t>::Signed;

namespace QEmuPrivate {
    template <typename Char>
    struct IsCompatibleCharTypeHelper
        : std::integral_constant<bool,
                                 std::is_same<Char, QChar>::value ||
                                 std::is_same<Char, ushort>::value ||
    #if defined(Q_COMPILER_UNICODE_STRINGS)
                                 std::is_same<Char, char16_t>::value ||
    #endif
                                 (std::is_same<Char, wchar_t>::value && sizeof(wchar_t) == sizeof(QChar))> {};
    template <typename Char>
    struct IsCompatibleCharType
        : IsCompatibleCharTypeHelper<typename std::remove_cv<typename std::remove_reference<Char>::type>::type> {};

    template <typename Array>
    struct IsCompatibleArrayHelper : std::false_type {};
    template <typename Char, size_t N>
    struct IsCompatibleArrayHelper<Char[N]>
        : IsCompatibleCharType<Char> {};
    template <typename Array>
    struct IsCompatibleArray
        : IsCompatibleArrayHelper<typename std::remove_cv<typename std::remove_reference<Array>::type>::type> {};

    template <typename Pointer>
    struct IsCompatiblePointerHelper : std::false_type {};
    template <typename Char>
    struct IsCompatiblePointerHelper<Char*>
        : IsCompatibleCharType<Char> {};
    template <typename Pointer>
    struct IsCompatiblePointer
        : IsCompatiblePointerHelper<typename std::remove_cv<typename std::remove_reference<Pointer>::type>::type> {};

    template <typename T>
    struct IsCompatibleStdBasicStringHelper : std::false_type {};
    template <typename Char, typename...Args>
    struct IsCompatibleStdBasicStringHelper<std::basic_string<Char, Args...> >
        : IsCompatibleCharType<Char> {};

    template <typename T>
    struct IsCompatibleStdBasicString
        : IsCompatibleStdBasicStringHelper<
            typename std::remove_cv<typename std::remove_reference<T>::type>::type
          > {};

    inline qsizetype qustrlen(const ushort *str) Q_DECL_NOTHROW
    {
#ifdef __SSE2__
        // find the 16-byte alignment immediately prior or equal to str
        quintptr misalignment = quintptr(str) & 0xf;
        Q_ASSERT((misalignment & 1) == 0);
        const ushort *ptr = str - (misalignment / 2);

        // load 16 bytes and see if we have a null
        // (aligned loads can never segfault)
        const __m128i zeroes = _mm_setzero_si128();
        __m128i data = _mm_load_si128(reinterpret_cast<const __m128i *>(ptr));
        __m128i comparison = _mm_cmpeq_epi16(data, zeroes);
        quint32 mask = _mm_movemask_epi8(comparison);

        // ignore the result prior to the beginning of str
        mask >>= misalignment;

        // Have we found something in the first block? Need to handle it now
        // because of the left shift above.
        if (mask)
            return qCountTrailingZeroBits(quint32(mask)) / 2;

        do {
            ptr += 8;
            data = _mm_load_si128(reinterpret_cast<const __m128i *>(ptr));

            comparison = _mm_cmpeq_epi16(data, zeroes);
            mask = _mm_movemask_epi8(comparison);
        } while (mask == 0);

        // found a null
        uint idx = qCountTrailingZeroBits(quint32(mask));
        return ptr - str + idx / 2;
#else
        qsizetype result = 0;

        if (sizeof(wchar_t) == sizeof(ushort))
            return wcslen(reinterpret_cast<const wchar_t *>(str));

        while (*str++)
            ++result;
        return result;
#endif
    }

} // namespace QEmuPrivate

class QEmuStringView : public QString
{
public:
    typedef QChar storage_type;
    typedef const QChar value_type;
    typedef std::ptrdiff_t difference_type;
    typedef qsizetype size_type;
    typedef value_type &reference;
    typedef value_type &const_reference;
    typedef value_type *pointer;
    typedef value_type *const_pointer;

    typedef pointer iterator;
    typedef const_pointer const_iterator;
    typedef std::reverse_iterator<iterator> reverse_iterator;
    typedef std::reverse_iterator<const_iterator> const_reverse_iterator;

    template <typename Char>
    using if_compatible_char = typename std::enable_if<QEmuPrivate::IsCompatibleCharType<Char>::value, bool>::type;

    template <typename Array>
    using if_compatible_array = typename std::enable_if<QEmuPrivate::IsCompatibleArray<Array>::value, bool>::type;

    template <typename Pointer>
    using if_compatible_pointer = typename std::enable_if<QEmuPrivate::IsCompatiblePointer<Pointer>::value, bool>::type;

    template <typename T>
    using if_compatible_string = typename std::enable_if<QEmuPrivate::IsCompatibleStdBasicString<T>::value, bool>::type;

    template <typename T>
    using if_compatible_qstring_like = typename std::enable_if<std::is_same<T, QString>::value || std::is_same<T, QStringRef>::value, bool>::type;

    template <typename T>
    using if_compatible_qstringview_like = typename std::enable_if<std::is_same<T, QStringView>::value || std::is_same<T, QEmuStringView>::value, bool>::type;

    template <typename Char, size_t N>
    static Q_DECL_CONSTEXPR qsizetype lengthHelperArray(const Char (&)[N]) Q_DECL_NOTHROW
    {
        return qsizetype(N - 1);
    }

    template <typename Char>
    static qsizetype lengthHelperPointer(const Char *str) Q_DECL_NOTHROW
    {
        if (!str) {
            return 0;
        }
#if defined(Q_CC_GNU) && !defined(Q_CC_CLANG) && !defined(Q_CC_INTEL)
        if (__builtin_constant_p(*str)) {
            qsizetype result = 0;
            while (*str++)
                ++result;
            return result;
        }
#endif
        return QEmuPrivate::qustrlen(reinterpret_cast<const ushort *>(str));
    }
    static qsizetype lengthHelperPointer(const QChar *str) Q_DECL_NOTHROW
    {
        return str ? QEmuPrivate::qustrlen(reinterpret_cast<const ushort *>(str)) : 0;
    }

    template <typename Char>
    static const storage_type *castHelper(const Char *str) Q_DECL_NOTHROW
    { return reinterpret_cast<const storage_type*>(str); }
    static Q_DECL_CONSTEXPR const storage_type *castHelper(const storage_type *str) Q_DECL_NOTHROW
    { return str; }
    template <typename Char>
    static Q_DECL_CONSTEXPR const storage_type *castHelper(const std::basic_string<Char> str) Q_DECL_NOTHROW
    { return reinterpret_cast<const storage_type*>(str.data()); }

public:
    inline QEmuStringView()
        : QString() {}
    QEmuStringView(std::nullptr_t) Q_DECL_NOTHROW
        : QString(), m_isNull(true) {}
    inline QEmuStringView(const QString &that)
    {
        *this = that;
    }
    inline QEmuStringView(const QString *that)
    {
        if (that) {
            *this = *that;
        } else {
            clear();
            m_isNull = true;
        }
    }
    inline QEmuStringView(const char16_t *str)
        : QString(str ? QString::fromUtf16(reinterpret_cast<const char16_t *>(str)) : nullptr)
        , m_hasData(true), m_data(str)
    {
        if (!str) {
            m_isNull = true;
        }
    }

    inline QEmuStringView(const char *str)
        : QString(str ? QString::fromLocal8Bit(str, -1) : nullptr)
        , m_hasData(true), m_data(str)
    {
        if (!str) {
            m_isNull = true;
        }
    }

//     inline QEmuStringView(const QChar *str, qsizetype len=-1)
//         : QString(str,len) {}
template <typename Char, if_compatible_char<Char> = true>
    inline Q_DECL_CONSTEXPR QEmuStringView(const Char *str, qsizetype len)
        : QString(castHelper(str),len), m_isNull(str==nullptr)
        , m_hasData(true), m_data(str) {}
template <typename Char, if_compatible_char<Char> = true>
    inline Q_DECL_CONSTEXPR QEmuStringView(const Char *f, const Char *l)
        : QEmuStringView(f, l - f) {}
template <typename Array, if_compatible_array<Array> = true>
    Q_DECL_CONSTEXPR QEmuStringView(const Array &str) Q_DECL_NOTHROW
        : QEmuStringView(str, lengthHelperArray(str)) {}

template <typename Pointer, if_compatible_pointer<Pointer> = true>
    Q_DECL_CONSTEXPR QEmuStringView(const Pointer &str) Q_DECL_NOTHROW
        : QEmuStringView(str, str ? lengthHelperPointer(str) : 0) {}

template <typename String, if_compatible_qstring_like<String> = true>
    inline Q_DECL_CONSTEXPR QEmuStringView(const String &str) Q_DECL_NOTHROW
        : QEmuStringView(str.isNull() ? nullptr : str.data(), qsizetype(str.size())) {}
template <typename StdBasicString, if_compatible_string<StdBasicString> = true>
    QEmuStringView(const StdBasicString &str) Q_DECL_NOTHROW
        : QEmuStringView(str.data(), qsizetype(str.size())) {}

    inline QEmuStringView(const std::wstring str)
        : QString(QString::fromStdWString(str)) {}
    inline QEmuStringView(const wchar_t *str)
        : QString(str ? QString::fromStdWString(str) : nullptr)
        , m_hasData(true), m_data(str)
    {
        if (!str) {
            m_isNull = true;
        }
    }


    inline bool empty() {return QString::size() == 0 ; }
    Q_REQUIRED_RESULT inline QChar first() const { return at(0); }
    Q_REQUIRED_RESULT inline QChar front() const { return at(0); }
    Q_REQUIRED_RESULT inline QChar last()  const { return at(size() - 1); }
    Q_REQUIRED_RESULT inline QChar back()  const { return at(size() - 1); }

    inline QString toString() const
    {
        // detour via QStringRef::toString() which makes the required deep copy
        return QStringRef(this).toString();
    }

    inline QEmuStringView &operator=(const QString &other) Q_DECL_NOTHROW
    {
        *(static_cast<QString*>(this)) = other;
        m_hasData = m_isNull = false;
        m_data = nullptr;
        return *this;
    }
    inline QEmuStringView &operator=(const QString *other) Q_DECL_NOTHROW
    {
        if (other) {
            *(static_cast<QString*>(this)) = *other;
            m_isNull = false;
        } else {
            QString::clear();
            m_isNull = true;
        }
        m_hasData = false;
        m_data = nullptr;
        return *this;
    }
    Q_REQUIRED_RESULT const QChar operator[](qsizetype n) const
    { return Q_ASSERT10(n >= 0), Q_ASSERT10(n < size()), at(n); }

    inline const QChar *unicode() const
    {
        return m_isNull ? nullptr : QString::unicode();
    }
    inline const_pointer data() const
    {
        return m_isNull ? nullptr :
            m_hasData ? static_cast<const_pointer>(m_data) : QString::data();
    }
    inline QChar *data()
    {
        // another nice hack to return a non-const version of m_data...
        void** pp = const_cast<void**>(&m_data);
        return m_isNull ? nullptr :
            m_hasData ? static_cast<QChar*>(*pp) : QString::data();
    }
    inline const QChar *constData() const
    {
        return m_isNull ? nullptr :
            m_hasData ? static_cast<const QChar*>(m_data) :QString::constData();
    }

    const ushort *utf16() const
    {
        return (m_isNull || isNull()) ? nullptr : QString::utf16();
    }

    char *toPrettyUnicode() const
    {
        auto p = reinterpret_cast<const ushort *>(utf16());
        auto length = size();
        // keep it simple for the vast majority of cases
        bool trimmed = false;
        QScopedArrayPointer<char> buffer(new char[256]);
        const ushort *end = p + length;
        char *dst = buffer.data();

        *dst++ = '"';
        for ( ; p != end; ++p) {
            if (dst - buffer.data() > 245) {
                // plus the the quote, the three dots and NUL, it's 250, 251 or 255
                trimmed = true;
                break;
            }

            if (*p < 0x7f && *p >= 0x20 && *p != '\\' && *p != '"') {
                *dst++ = *p;
                continue;
            }

            // write as an escape sequence
            // this means we may advance dst to buffer.data() + 246 or 250
            *dst++ = '\\';
            switch (*p) {
            case 0x22:
            case 0x5c:
                *dst++ = uchar(*p);
                break;
            case 0x8:
                *dst++ = 'b';
                break;
            case 0xc:
                *dst++ = 'f';
                break;
            case 0xa:
                *dst++ = 'n';
                break;
            case 0xd:
                *dst++ = 'r';
                break;
            case 0x9:
                *dst++ = 't';
                break;
            default:
                *dst++ = 'u';
                *dst++ = toHexUpper(*p >> 12);
                *dst++ = toHexUpper(*p >> 8);
                *dst++ = toHexUpper(*p >> 4);
                *dst++ = toHexUpper(*p);
            }
        }

        *dst++ = '"';
        if (trimmed) {
            *dst++ = '.';
            *dst++ = '.';
            *dst++ = '.';
        }
        *dst++ = '\0';
        return buffer.take();
    }

private:

    static Q_DECL_CONSTEXPR inline char toHexUpper(uint value) Q_DECL_NOTHROW
    {
        return "0123456789ABCDEF"[value & 0xF];
    }
    bool m_isNull = false;
    bool m_hasData = false;
    const void *m_data = nullptr;
};

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs == QEmuStringView(rhs,1); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs != QEmuStringView(rhs,1); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs <  QEmuStringView(rhs,1); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs <= QEmuStringView(rhs,1); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs >  QEmuStringView(rhs,1); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(QEmuStringView lhs, const Char rhs) Q_DECL_NOTHROW { return lhs >= QEmuStringView(rhs,1); }

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) == rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) != rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) <  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) <= rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) >  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(const Char lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs,1) >= rhs; }

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs == QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs != QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs <  QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs <= QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs >  QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(QEmuStringView lhs, const Char* rhs) Q_DECL_NOTHROW { return lhs >= QEmuStringView(rhs); }

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) == rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) != rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) <  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) <= rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) >  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(const Char* lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) >= rhs; }

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs == QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs != QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs <  QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs <= QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs >  QEmuStringView(rhs); }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(QEmuStringView lhs, const std::basic_string<Char> rhs) Q_DECL_NOTHROW { return lhs >= QEmuStringView(rhs); }

template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator==(const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) == rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator!=(const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) != rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator< (const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) <  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator<=(const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) <= rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator> (const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) >  rhs; }
template <typename Char, QEmuStringView::if_compatible_char<Char> = true>
inline bool operator>=(const std::basic_string<Char> lhs, QEmuStringView rhs) Q_DECL_NOTHROW { return QEmuStringView(lhs) >= rhs; }

#ifndef QSTRINGVIEW_H
/*    namespace QTest
    {

        template <> inline char *toString(const QEmuStringView &str)
        {
            return str.toPrettyUnicode();
        }

        template <typename T1, typename T2>
        inline bool qCompare(const T1 &t1, const T2 &t2, const char *actual, const char *expected,
                             const char *file, int line)
        {
            return compare_helper(t1 == t2, "Compared values are not the same",
                                  toString(t1), toString(t2), actual, expected, file, line);
        }

    }
*/
#endif

#ifdef QSTRINGVIEW_EMULATE
#define QStringView QEmuStringView
#undef QStringViewLiteral
#define QStringViewLiteral(str) QStringView(QStringLiteral(str))
#endif

// added by RJVB
template <typename String, QEmuStringView::if_compatible_qstringview_like<String> = true>
inline QDebug operator << (QDebug d, const String* q)
{
    d.nospace() << "QStringView*(" << q->toString() << ")";
    return d.space();
}

#endif // QEMUSTRINGVIEW_H

