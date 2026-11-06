package com.cubiccode.moreki

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * The Moreki home-screen widget. It only DISPLAYS text that the Flutter app
 * already worked out (see widget_snapshot.dart). No maths happens here.
 */
class MorekiWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // Before the app has ever run there is no data: say so honestly.
        val leftLabel = widgetData.getString("left_label", null) ?: "LEFT TO SPEND"
        val leftValue = widgetData.getString("left_value", null) ?: "Open Moreki"
        val leftCaption = widgetData.getString("left_caption", null) ?: "to set up this widget"
        val scoreLabel = widgetData.getString("score_label", null) ?: "MOREKI SCORE"
        val scoreValue = widgetData.getString("score_value", null) ?: "Locked"
        val scoreCaption = widgetData.getString("score_caption", null) ?: ""
        val asOf = widgetData.getString("as_of", null) ?: ""
        val overBudget = widgetData.getString("over_budget", null) == "1"
        val scoreLocked = widgetData.getString("score_locked", null) != "0"

        val description = buildString {
            append("Left to spend: $leftValue. $leftCaption. ")
            append(
                if (scoreLocked) "Moreki Score locked. "
                else "Moreki Score $scoreValue $scoreCaption. "
            )
            if (asOf.isNotEmpty()) append("$asOf.")
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.moreki_widget).apply {
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                setContentDescription(R.id.widget_root, description)

                setTextViewText(R.id.widget_left_label, leftLabel)
                setTextViewText(R.id.widget_as_of, asOf)
                setTextViewText(R.id.widget_left_value, leftValue)
                setTextViewText(R.id.widget_left_caption, leftCaption)
                setTextViewText(R.id.widget_score_label, scoreLabel)
                setTextViewText(R.id.widget_score_value, scoreValue)
                setTextViewText(R.id.widget_score_caption, scoreCaption)

                // Red is never the only signal: the caption also says "Over budget".
                setTextColor(
                    R.id.widget_left_value,
                    Color.parseColor(if (overBudget) "#FF514A" else "#FFFFFF"),
                )
                setTextColor(
                    R.id.widget_score_value,
                    Color.parseColor(if (scoreLocked) "#A6A6A6" else "#32E875"),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}